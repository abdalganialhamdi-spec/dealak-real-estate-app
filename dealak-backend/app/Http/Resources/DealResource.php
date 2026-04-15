<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DealResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'property' => new PropertyResource($this->whenLoaded('property')),
            'buyer' => new UserResource($this->whenLoaded('buyer')),
            'seller' => new UserResource($this->whenLoaded('seller')),
            'agent' => new UserResource($this->whenLoaded('agent')),
            'amount' => (float) $this->amount,
            'currency' => $this->currency,
            'commission' => (float) $this->commission,
            'status' => $this->status,
            'start_date' => $this->start_date?->toDateString(),
            'end_date' => $this->end_date?->toDateString(),
            'notes' => $this->notes,
            'total_paid' => (float) $this->whenLoaded('payments', fn() => $this->payments->where('status', 'COMPLETED')->sum('amount'), 0),
            'payments' => $this->whenLoaded('payments'),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
