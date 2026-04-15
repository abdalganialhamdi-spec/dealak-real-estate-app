<?php

namespace Database\Seeders;

use App\Models\Property;
use App\Models\User;
use Illuminate\Database\Seeder;

class PropertySeeder extends Seeder
{
    public function run(): void
    {
        $agents = User::where('role', 'AGENT')->get();
        $sellers = User::where('role', 'SELLER')->get();

        $cities = ['دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية', 'طرطوس', 'دير الزور', 'الرقة', 'إدلب', 'درعا', 'السويداء', 'القنيطرة'];
        $types = ['APARTMENT', 'HOUSE', 'VILLA', 'LAND', 'COMMERCIAL', 'OFFICE', 'WAREHOUSE', 'FARM'];
        $listings = ['SALE', 'RENT_MONTHLY', 'RENT_YEARLY', 'RENT_DAILY'];

        foreach ($sellers as $seller) {
            Property::factory(rand(2, 5))->create([
                'owner_id' => $seller->id,
                'agent_id' => $agents->random()->id ?? null,
                'city' => fake()->randomElement($cities),
                'property_type' => fake()->randomElement($types),
                'listing_type' => fake()->randomElement($listings),
            ]);
        }
    }
}
