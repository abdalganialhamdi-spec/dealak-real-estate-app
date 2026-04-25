<?php

namespace App\Services;

use App\Models\Property;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class SearchService
{
    public function search(array $filters): LengthAwarePaginator
    {
        $query = Property::with(['owner', 'images'])
            ->where('status', '!=', 'DRAFT');

        if (!empty($filters['q'])) {
            $searchTerm = $filters['q'];
            $query->where(function ($q) use ($searchTerm) {
                $q->where('title', 'LIKE', "%{$searchTerm}%")
                    ->orWhere('description', 'LIKE', "%{$searchTerm}%")
                    ->orWhere('city', 'LIKE', "%{$searchTerm}%")
                    ->orWhere('district', 'LIKE', "%{$searchTerm}%")
                    ->orWhere('address', 'LIKE', "%{$searchTerm}%");
            });
        }

        if (!empty($filters['property_type'])) {
            $query->where('property_type', $filters['property_type']);
        }

        if (!empty($filters['listing_type'])) {
            $query->where('listing_type', $filters['listing_type']);
        }

        if (!empty($filters['city'])) {
            $query->where('city', $filters['city']);
        }

        if (!empty($filters['district'])) {
            $query->where('district', $filters['district']);
        }

        if (!empty($filters['min_price'])) {
            $query->where('price', '>=', $filters['min_price']);
        }

        if (!empty($filters['max_price'])) {
            $query->where('price', '<=', $filters['max_price']);
        }

        if (!empty($filters['min_area'])) {
            $query->where('area_sqm', '>=', $filters['min_area']);
        }

        if (!empty($filters['max_area'])) {
            $query->where('area_sqm', '<=', $filters['max_area']);
        }

        if (!empty($filters['bedrooms'])) {
            $query->where('bedrooms', '>=', $filters['bedrooms']);
        }

        if (!empty($filters['bathrooms'])) {
            $query->where('bathrooms', '>=', $filters['bathrooms']);
        }

        $allowedSortColumns = ['created_at', 'price', 'area_sqm', 'bedrooms', 'bathrooms', 'id'];
        $sortBy = in_array($filters['sort_by'] ?? 'created_at', $allowedSortColumns) ? ($filters['sort_by'] ?? 'created_at') : 'created_at';
        $sortDir = in_array($filters['sort_dir'] ?? 'desc', ['asc', 'desc']) ? ($filters['sort_dir'] ?? 'desc') : 'desc';

        $query->orderBy($sortBy, $sortDir);

        return $query->paginate($filters['per_page'] ?? 20);
    }

    public function searchNearby(float $lat, float $lng, float $radiusKm, array $filters = []): LengthAwarePaginator
    {
        $query = Property::query()
            ->selectRaw("*, (6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) AS distance_km", [$lat, $lng, $lat])
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->having('distance_km', '<=', $radiusKm)
            ->where('status', 'AVAILABLE');

        if (!empty($filters['property_type'])) {
            $query->where('property_type', $filters['property_type']);
        }

        if (!empty($filters['listing_type'])) {
            $query->where('listing_type', $filters['listing_type']);
        }

        return $query->orderBy('distance_km')->paginate($filters['per_page'] ?? 20);
    }
}
