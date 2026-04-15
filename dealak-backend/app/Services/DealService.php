<?php

namespace App\Services;

use App\Models\Deal;
use App\Models\Payment;
use App\Models\Property;
use App\Models\User;

class DealService
{
    public function createDeal(array $data, User $user): Deal
    {
        $property = Property::findOrFail($data['property_id']);

        return Deal::create([
            'property_id' => $property->id,
            'buyer_id' => $data['buyer_id'] ?? $user->id,
            'seller_id' => $property->owner_id,
            'agent_id' => $property->agent_id,
            'amount' => $data['amount'] ?? $property->price,
            'currency' => $data['currency'] ?? $property->currency,
            'commission' => $data['commission'] ?? 0,
            'status' => 'PENDING',
            'start_date' => $data['start_date'] ?? null,
            'end_date' => $data['end_date'] ?? null,
            'notes' => $data['notes'] ?? null,
        ]);
    }

    public function updateDealStatus(Deal $deal, array $data): Deal
    {
        $deal->update($data);

        if (($data['status'] ?? null) === 'COMPLETED') {
            $deal->property()->update(['status' => 'SOLD']);
        }

        return $deal;
    }

    public function recordPayment(Deal $deal, array $data, User $user): Payment
    {
        return $deal->payments()->create([
            'payer_id' => $user->id,
            'payee_id' => $deal->seller_id,
            'amount' => $data['amount'],
            'currency' => $data['currency'] ?? $deal->currency,
            'method' => $data['method'],
            'status' => 'COMPLETED',
            'reference_number' => $data['reference_number'] ?? null,
            'notes' => $data['notes'] ?? null,
            'paid_at' => $data['paid_at'] ?? now()->toDateString(),
        ]);
    }
}
