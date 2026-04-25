<?php

namespace Database\Seeders;

use App\Models\SystemSetting;
use Illuminate\Database\Seeder;

class SystemSettingSeeder extends Seeder
{
    public function run(): void
    {
        $settings = [
            ['key' => 'app_name', 'value' => 'DEALAK', 'value_type' => 'STRING', 'group' => 'general'],
            ['key' => 'default_currency', 'value' => 'SYP', 'value_type' => 'STRING', 'group' => 'general'],
            ['key' => 'commission_rate', 'value' => '2.5', 'value_type' => 'STRING', 'group' => 'deals'],
            ['key' => 'max_images_per_property', 'value' => '20', 'value_type' => 'INTEGER', 'group' => 'properties'],
            ['key' => 'auto_approve_properties', 'value' => 'false', 'value_type' => 'BOOLEAN', 'group' => 'properties'],
            ['key' => 'contact_email', 'value' => 'info@dealak.com', 'value_type' => 'STRING', 'group' => 'general'],
            ['key' => 'contact_phone', 'value' => '+963-XX-XXXXXXX', 'value_type' => 'STRING', 'group' => 'general'],
        ];

        foreach ($settings as $setting) {
            SystemSetting::create($setting);
        }
    }
}