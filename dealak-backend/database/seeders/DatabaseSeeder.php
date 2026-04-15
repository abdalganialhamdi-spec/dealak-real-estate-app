<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\SystemSetting;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'first_name' => 'Admin',
            'last_name' => 'Dealak',
            'email' => 'admin@dealak.com',
            'password' => 'Admin123',
            'role' => 'ADMIN',
            'is_verified' => true,
            'is_active' => true,
        ]);

        SystemSetting::insert([
            ['key' => 'site_name', 'value' => 'DEALAK', 'value_type' => 'STRING'],
            ['key' => 'currency', 'value' => 'SYP', 'value_type' => 'STRING'],
        ]);

        $this->call([
            GovernorateSeeder::class,
            UserSeeder::class,
            PropertySeeder::class,
        ]);
    }
}
