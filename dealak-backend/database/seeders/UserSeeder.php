<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@dealak.com'],
            [
                'first_name' => 'Admin',
                'last_name' => 'Dealak',
                'password' => 'Admin123',
                'role' => 'ADMIN',
                'is_verified' => true,
                'is_active' => true,
            ]
        );

        User::factory(10)->create(['role' => 'AGENT']);
        User::factory(20)->create(['role' => 'SELLER']);
        User::factory(30)->create(['role' => 'BUYER']);
    }
}
