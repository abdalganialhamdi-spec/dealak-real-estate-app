<?php

namespace Database\Seeders;

use App\Models\SystemSetting;
use Illuminate\Database\Seeder;

class SystemSettingSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            ['key' => 'app_name', 'value' => 'DEALAK', 'type' => 'string', 'group' => 'general'],
            ['key' => 'default_currency', 'value' => 'SYP', 'type' => 'string', 'group' => 'general'],
            ['key' => 'commission_rate', 'value' => '2.5', 'type' => 'float', 'group' => 'deals'],
            ['key' => 'max_images_per_property', 'value' => '20', 'type' => 'integer', 'group' => 'properties'],
            ['key' => 'auto_approve_properties', 'value' => 'false', 'type' => 'boolean', 'group' => 'properties'],
            ['key' => 'contact_email', 'value' => 'info@dealak.com', 'type' => 'string', 'group' => 'general'],
            ['key' => 'contact_phone', 'value' => '+963-XX-XXXXXXX', 'type' => 'string', 'group' => 'general'],
        ];

        foreach ($settings as $setting) {
            SystemSetting::create($setting);
        }
    }
}
