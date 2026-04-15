<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PropertyResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'description' => $this->description,
            'property_type' => $this->property_type,
            'status' => $this->status,
            'listing_type' => $this->listing_type,
            'price' => (float) $this->price,
            'currency' => $this->currency,
            'area_sqm' => $this->area_sqm ? (float) $this->area_sqm : null,
            'bedrooms' => $this->bedrooms,
            'bathrooms' => $this->bathrooms,
            'floors' => $this->floors,
            'year_built' => $this->year_built,
            'address' => $this->address,
            'city' => $this->city,
            'district' => $this->district,
            'latitude' => $this->latitude ? (float) $this->latitude : null,
            'longitude' => $this->longitude ? (float) $this->longitude : null,
            'is_featured' => $this->is_featured,
            'is_negotiable' => $this->is_negotiable,
            'view_count' => $this->view_count,
            'average_rating' => round($this->whenLoaded('reviews', fn() => $this->reviews->avg('rating') ?? 0, 0), 1),
            'owner' => new UserResource($this->whenLoaded('owner')),
            'agent' => new UserResource($this->whenLoaded('agent')),
            'images' => PropertyImageResource::collection($this->whenLoaded('images')),
            'features' => $this->whenLoaded('features'),
            'reviews' => ReviewResource::collection($this->whenLoaded('reviews')),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
