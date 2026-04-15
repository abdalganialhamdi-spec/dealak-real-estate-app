<?php

namespace App\Http\Requests\Request;

use Illuminate\Foundation\Http\FormRequest;

class StoreRequestRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'property_type' => 'nullable|string',
            'listing_type' => 'nullable|string',
            'city' => 'nullable|string',
            'district' => 'nullable|string',
            'min_price' => 'nullable|numeric',
            'max_price' => 'nullable|numeric',
            'min_area' => 'nullable|numeric',
            'max_area' => 'nullable|numeric',
            'min_bedrooms' => 'nullable|integer',
            'max_bedrooms' => 'nullable|integer',
            'notes' => 'nullable|string',
        ];
    }
}
