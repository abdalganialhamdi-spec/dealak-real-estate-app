<?php

namespace Database\Factories;

use App\Models\Property;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class PropertyFactory extends Factory
{
    protected $model = Property::class;

    public function definition(): array
    {
        $cities = ['دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية', 'طرطوس'];
        $districts = ['المزة', 'كفرسوسة', 'الشامية', 'باب توما', 'الصالحية', 'الميدان'];

        return [
            'owner_id' => User::factory(),
            'title' => fake()->randomElement(['شقة للبيع', 'منزل للإيجار', 'فيلا فاخرة', 'أرض تجارية', 'مكتب للإيجار']),
            'description' => fake()->paragraph(),
            'property_type' => fake()->randomElement(['APARTMENT', 'HOUSE', 'VILLA', 'LAND', 'COMMERCIAL', 'OFFICE']),
            'status' => fake()->randomElement(['AVAILABLE', 'AVAILABLE', 'AVAILABLE', 'PENDING']),
            'listing_type' => fake()->randomElement(['SALE', 'RENT_MONTHLY', 'RENT_YEARLY']),
            'price' => fake()->randomFloat(2, 50000, 50000000),
            'currency' => 'SYP',
            'area_sqm' => fake()->randomFloat(2, 50, 500),
            'bedrooms' => fake()->numberBetween(1, 6),
            'bathrooms' => fake()->numberBetween(1, 3),
            'year_built' => fake()->numberBetween(1990, 2024),
            'address' => fake()->streetAddress(),
            'city' => fake()->randomElement($cities),
            'district' => fake()->randomElement($districts),
            'latitude' => fake()->latitude(32.0, 37.5),
            'longitude' => fake()->longitude(35.0, 42.5),
            'is_featured' => fake()->boolean(20),
            'is_negotiable' => fake()->boolean(70),
        ];
    }
}
