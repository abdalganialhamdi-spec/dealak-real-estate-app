<?php

namespace App\Services;

use App\Models\Property;
use App\Models\User;

class PropertyService
{
    public function createProperty(array $data, User $user): Property
    {
        $data['owner_id'] = $user->id;
        $data['status'] = $data['status'] ?? 'AVAILABLE';

        return Property::create($data);
    }

    public function updateProperty(Property $property, array $data): Property
    {
        $property->update($data);
        return $property;
    }
}
