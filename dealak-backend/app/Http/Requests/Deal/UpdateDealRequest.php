<?php

namespace App\Http\Requests\Deal;

use Illuminate\Foundation\Http\FormRequest;

class UpdateDealRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'status' => 'sometimes|in:PENDING,IN_PROGRESS,COMPLETED,CANCELLED,DISPUTED',
            'commission' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string',
        ];
    }
}
