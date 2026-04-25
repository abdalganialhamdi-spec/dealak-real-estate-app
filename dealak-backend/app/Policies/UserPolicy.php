<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->role === 'ADMIN';
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $authenticatedUser, User $user): bool
    {
        // Users can view their own profile or admins can view any
        return $authenticatedUser->id === $user->id || $authenticatedUser->role === 'ADMIN';
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $authenticatedUser, User $user): bool
    {
        // Users can update their own profile or admins can update any
        return $authenticatedUser->id === $user->id || $authenticatedUser->role === 'ADMIN';
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $authenticatedUser, User $user): bool
    {
        // Only admins can delete users, and not themselves
        return $authenticatedUser->role === 'ADMIN' && $authenticatedUser->id !== $user->id;
    }

    /**
     * Determine whether the user can manage user status.
     */
    public function manageStatus(User $user): bool
    {
        return $user->role === 'ADMIN';
    }
}