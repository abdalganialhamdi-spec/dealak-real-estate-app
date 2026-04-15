<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Message\SendMessageRequest;
use App\Http\Resources\MessageResource;
use App\Models\Conversation;
use App\Services\MessageService;
use Illuminate\Http\JsonResponse;

class MessageController extends Controller
{
    public function __construct(private MessageService $messageService) {}

    public function store(SendMessageRequest $request, int $conversationId): JsonResponse
    {
        $conversation = Conversation::where('id', $conversationId)
            ->where(function ($q) use ($request) {
                $q->where('participant_one_id', $request->user()->id)
                    ->orWhere('participant_two_id', $request->user()->id);
            })->firstOrFail();

        $message = $this->messageService->sendMessage(
            $conversation,
            $request->user(),
            $request->input('body'),
            $request->input('type', 'TEXT'),
            $request->input('metadata')
        );

        return response()->json(new MessageResource($message), 201);
    }
}
