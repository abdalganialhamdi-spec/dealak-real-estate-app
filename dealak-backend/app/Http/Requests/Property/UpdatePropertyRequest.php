<?php

namespace App\Http\Requests\Property;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePropertyRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'title' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'property_type' => 'sometimes|in:APARTMENT,HOUSE,VILLA,LAND,COMMERCIAL,OFFICE,WAREHOUSE,FARM',
            'status' => 'sometimes|in:AVAILABLE,SOLD,RENTED,PENDING,RESERVED,DRAFT',
            'listing_type' => 'sometimes|in:SALE,RENT_MONTHLY,RENT_YEARLY,RENT_DAILY',
            'price' => 'sometimes|numeric|min:0',
            'area_sqm' => 'nullable|numeric|min:0',
            'bedrooms' => 'nullable|integer|min:0',
            'bathrooms' => 'nullable|integer|min:0',
            'address' => 'nullable|string',
            'city' => 'sometimes|string',
            'district' => 'nullable|string',
            'is_featured' => 'boolean',
            'is_negotiable' => 'boolean',
        ];
    }
}
