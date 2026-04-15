<?php

namespace Database\Factories;

use App\Models\Deal;
use App\Models\Property;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class DealFactory extends Factory
{
    protected $model = Deal::class;

    public function definition(): array
    {
        return [
            'property_id' => Property::factory(),
            'buyer_id' => User::factory(),
            'seller_id' => User::factory(),
            'amount' => fake()->randomFloat(2, 100000, 10000000),
            'currency' => 'SYP',
            'commission' => fake()->randomFloat(2, 0, 500000),
            'status' => fake()->randomElement(['PENDING', 'IN_PROGRESS', 'COMPLETED']),
        ];
    }
}
