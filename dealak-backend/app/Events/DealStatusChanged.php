<?php

namespace App\Events;

use App\Models\Deal;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class DealStatusChanged implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Deal $deal, public string $oldStatus) {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel("user.{$this->deal->buyer_id}"),
            new PrivateChannel("user.{$this->deal->seller_id}"),
        ];
    }

    public function broadcastWith(): array
    {
        return [
            'deal_id' => $this->deal->id,
            'old_status' => $this->oldStatus,
            'new_status' => $this->deal->status,
        ];
    }
}
