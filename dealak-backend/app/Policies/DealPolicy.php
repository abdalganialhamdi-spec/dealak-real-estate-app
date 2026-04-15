<?php

namespace App\Policies;

use App\Models\Deal;
use App\Models\User;

class DealPolicy
{
    public function view(User $user, Deal $deal): bool
    {
        return $user->id === $deal->buyer_id || $user->id === $deal->seller_id || $user->id === $deal->agent_id || $user->isAdmin();
    }

    public function update(User $user, Deal $deal): bool
    {
        return $user->id === $deal->buyer_id || $user->id === $deal->seller_id || $user->id === $deal->agent_id || $user->isAdmin();
    }
}
