<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PropertyRequestResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (int) $this->id,
            'property_type' => $this->property_type,
            'listing_type' => $this->listing_type,
            'city' => $this->city,
            'district' => $this->district,
            'min_price' => $this->min_price ? (float) $this->min_price : null,
            'max_price' => $this->max_price ? (float) $this->max_price : null,
            'min_area' => $this->min_area ? (float) $this->min_area : null,
            'max_area' => $this->max_area ? (float) $this->max_area : null,
            'min_bedrooms' => (int) $this->min_bedrooms,
            'max_bedrooms' => (int) $this->max_bedrooms,
            'notes' => $this->notes,
            'status' => $this->status,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}