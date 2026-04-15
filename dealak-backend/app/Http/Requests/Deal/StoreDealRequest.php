<?php

namespace App\Http\Requests\Deal;

use Illuminate\Foundation\Http\FormRequest;

class StoreDealRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'property_id' => 'required|exists:properties,id',
            'buyer_id' => 'nullable|exists:users,id',
            'amount' => 'nullable|numeric|min:0',
            'currency' => 'nullable|string|size:3',
            'commission' => 'nullable|numeric|min:0',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after:start_date',
            'notes' => 'nullable|string',
        ];
    }
}
