<?php

namespace App\Http\Requests\Message;

use Illuminate\Foundation\Http\FormRequest;

class SendMessageRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'body' => 'required|string|max:5000',
            'type' => 'nullable|in:TEXT,IMAGE,PROPERTY_LINK',
            'metadata' => 'nullable|array',
        ];
    }
}
