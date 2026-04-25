<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (int) $this->id,
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'full_name' => $this->full_name,
            'email' => $this->email,
            'phone' => $this->phone,
            'role' => $this->role,
            'avatar_url' => $this->avatar_url,
            'bio' => $this->bio,
            'is_verified' => (bool) $this->is_verified,
            'is_active' => (bool) ($this->is_active ?? true),
            'properties_count' => $this->whenCounted('properties', fn($count) => (int) $count),
            'reviews_count' => $this->whenCounted('reviews', fn($count) => (int) $count),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
