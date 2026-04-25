<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SystemSetting extends Model
{
    protected $fillable = ['key', 'value', 'value_type', 'group', 'description'];

    protected static function cached(): array
    {
        return cache()->rememberForever('system_settings', function () {
            return static::all()->keyBy('key')->toArray();
        });
    }

    public static function get(string $key, mixed $default = null): mixed
    {
        $settings = static::cached();
        return $settings[$key]['value'] ?? $default;
    }

    public static function set(string $key, mixed $value, string $value_type = 'STRING', string $group = 'general'): void
    {
        static::updateOrCreate(
            ['key' => $key],
            ['value' => $value, 'value_type' => $value_type, 'group' => $group]
        );
        cache()->forget('system_settings');
    }
}
