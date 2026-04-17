<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ConversationCollection;
use App\Http\Resources\ConversationResource;
use App\Http\Resources\MessageResource;
use App\Models\Conversation;
use App\Models\Property;
use App\Services\MessageService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    public function __construct(private MessageService $messageService) {}

    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;
        $conversations = Conversation::with(['participantOne', 'participantTwo', 'property', 'lastMessage'])
            ->where(function ($q) use ($userId) {
                $q->where('participant_one_id', $userId)
                    ->orWhere('participant_two_id', $userId);
            })
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

        return response()->json([
            'data' => MessageResource::collection($messages->items()),
            'meta' => [
                'current_page' => $messages->currentPage(),
                'last_page' => $messages->lastPage(),
                'per_page' => $messages->perPage(),
                'total' => $messages->total(),
            ],
        ]);
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

    public function findOrCreateByProperty(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'property_id' => 'required|exists:properties,id',
            'message' => 'required|string|max:1000',
        ]);

        $property = Property::findOrFail($validated['property_id']);
        $recipientId = $property->owner_id;

        if ($recipientId === $request->user()->id) {
            return response()->json(['message' => 'لا يمكنك مراسلة نفسك'], 422);
        }

        $conversation = Conversation::firstOrCreate(
            [
                'participant_one_id' => min($request->user()->id, $recipientId),
                'participant_two_id' => max($request->user()->id, $recipientId),
            ],
            ['property_id' => $validated['property_id']]
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
}
