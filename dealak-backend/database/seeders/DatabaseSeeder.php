<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            GovernorateSeeder::class,
            UserSeeder::class,
            SystemSettingSeeder::class,
            PropertySeeder::class,
        ]);
    }
}
