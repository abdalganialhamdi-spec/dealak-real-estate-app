<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    public function register(array $data): array
    {
        $user = User::create([
            'first_name' => $data['first_name'],
            'last_name' => $data['last_name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? null,
            'password' => $data['password'],
            'role' => $data['role'] ?? 'BUYER',
        ]);

        $token = $user->createToken('auth-token', [$user->role])->plainTextToken;

        return compact('user', 'token');
    }

    public function login(array $data): array
    {
        $user = User::where('email', $data['email'])->first();

        if (!$user || !Hash::check($data['password'], $user->password)) {
            abort(401, 'بيانات الدخول غير صحيحة');
        }

        if (!$user->is_active) {
            abort(403, 'الحساب معطّل');
        }

        $token = $user->createToken('auth-token', [$user->role])->plainTextToken;
        $user->update(['last_login_at' => now()]);

        return compact('user', 'token');
    }
}
