<?php

namespace App\Services;

use App\Events\MessageSent;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;

class MessageService
{
    public function sendMessage(Conversation $conversation, User $sender, string $body, string $type = 'TEXT', ?array $metadata = null): Message
    {
        $message = $conversation->messages()->create([
            'sender_id' => $sender->id,
            'body' => $body,
            'type' => $type,
            'metadata' => $metadata,
        ]);

        $conversation->update(['last_message_at' => now()]);

        broadcast(new MessageSent($message))->toOthers();

        return $message->load('sender');
    }
}
