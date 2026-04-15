<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ConversationCollection;
use App\Http\Resources\ConversationResource;
use App\Http\Resources\MessageResource;
use App\Models\Conversation;
use App\Services\MessageService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    public function __construct(private MessageService $messageService) {}

    public function index(Request $request): JsonResponse
    {
        $conversations = Conversation::with(['participantOne', 'participantTwo', 'property', 'lastMessage'])
            ->where('participant_one_id', $request->user()->id)
            ->orWhere('participant_two_id', $request->user()->id)
            ->latest('last_message_at')
            ->paginate($request->per_page ?? 20);

        return response()->json(new ConversationCollection($conversations));
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'recipient_id' => 'required|exists:users,id',
            'property_id' => 'nullable|exists:properties,id',
            'message' => 'required|string|max:1000',
        ]);

        $conversation = Conversation::firstOrCreate(
            [
                'participant_one_id' => min($request->user()->id, $validated['recipient_id']),
                'participant_two_id' => max($request->user()->id, $validated['recipient_id']),
            ],
            ['property_id' => $validated['property_id'] ?? null]
        );

        $message = $this->messageService->sendMessage(
            $conversation,
            $request->user(),
            $validated['message']
        );

        return response()->json([
            'conversation' => new ConversationResource($conversation->fresh()),
            'message' => new MessageResource($message),
        ], 201);
    }

    public function messages(Request $request, int $id): JsonResponse
    {
        $conversation = Conversation::where(function ($q) use ($request, $id) {
            $q->where('id', $id)
                ->where(function ($q2) use ($request) {
                    $q2->where('participant_one_id', $request->user()->id)
                        ->orWhere('participant_two_id', $request->user()->id);
                });
        })->firstOrFail();

        $messages = $conversation->messages()
            ->with('sender')
            ->latest()
            ->paginate($request->per_page ?? 50);

        return response()->json(MessageResource::collection($messages));
    }

    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $conversation = Conversation::findOrFail($id);

        $conversation->messages()
            ->where('sender_id', '!=', $request->user()->id)
            ->where('is_read', false)
            ->update(['is_read' => true, 'read_at' => now()]);

        return response()->json(['message' => 'تم تعليم الرسائل كمقروءة']);
    }
}
