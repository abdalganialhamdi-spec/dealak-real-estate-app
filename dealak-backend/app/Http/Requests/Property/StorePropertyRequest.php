<?php

namespace App\Http\Requests\Property;

use Illuminate\Foundation\Http\FormRequest;

class StorePropertyRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'property_type' => 'required|in:APARTMENT,HOUSE,VILLA,LAND,COMMERCIAL,OFFICE,WAREHOUSE,FARM',
            'listing_type' => 'required|in:SALE,RENT_MONTHLY,RENT_YEARLY,RENT_DAILY',
            'price' => 'required|numeric|min:0',
            'currency' => 'nullable|string|size:3',
            'area_sqm' => 'nullable|numeric|min:0',
            'bedrooms' => 'nullable|integer|min:0',
            'bathrooms' => 'nullable|integer|min:0',
            'floors' => 'nullable|integer|min:0',
            'year_built' => 'nullable|integer|min:1900|max:' . date('Y'),
            'address' => 'nullable|string',
            'city' => 'required|string',
            'district' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_negotiable' => 'boolean',
        ];
    }
}
