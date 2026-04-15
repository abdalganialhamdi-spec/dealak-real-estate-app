<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class GovernorateSeeder extends Seeder
{
    public function run(): void
    {
        $governorates = [
            ['name_ar' => 'دمشق', 'name_en' => 'Damascus'],
            ['name_ar' => 'ريف دمشق', 'name_en' => 'Rif Dimashq'],
            ['name_ar' => 'حلب', 'name_en' => 'Aleppo'],
            ['name_ar' => 'حمص', 'name_en' => 'Homs'],
            ['name_ar' => 'حماة', 'name_en' => 'Hama'],
            ['name_ar' => 'اللاذقية', 'name_en' => 'Latakia'],
            ['name_ar' => 'طرطوس', 'name_en' => 'Tartus'],
            ['name_ar' => 'إدلب', 'name_en' => 'Idlib'],
            ['name_ar' => 'دير الزور', 'name_en' => 'Deir ez-Zor'],
            ['name_ar' => 'الرقة', 'name_en' => 'Raqqa'],
            ['name_ar' => 'الحسكة', 'name_en' => 'Al-Hasakah'],
            ['name_ar' => 'درعا', 'name_en' => 'Daraa'],
            ['name_ar' => 'السويداء', 'name_en' => "Al-Suwayda"],
            ['name_ar' => 'القنيطرة', 'name_en' => 'Quneitra'],
        ];

        foreach ($governorates as $gov) {
            DB::table('governorates')->insertOrIgnore([
                'name_ar' => $gov['name_ar'],
                'name_en' => $gov['name_en'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
