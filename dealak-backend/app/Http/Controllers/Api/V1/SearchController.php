<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\PropertyCollection;
use App\Models\Property;
use App\Models\SavedSearch;
use App\Services\SearchService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    public function __construct(private SearchService $searchService) {}

    public function search(Request $request): JsonResponse
    {
        $properties = $this->searchService->search($request->all());

        return response()->json(new PropertyCollection($properties));
    }

    public function nearby(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'radius' => 'nullable|numeric|min:0.1|max:100',
            'property_type' => 'nullable|string',
            'listing_type' => 'nullable|string',
        ]);

        $properties = $this->searchService->searchNearby(
            $validated['lat'],
            $validated['lng'],
            $validated['radius'] ?? 5,
            $validated
        );

        return response()->json(new PropertyCollection($properties));
    }

    public function suggestions(Request $request): JsonResponse
    {
        $query = $request->get('q', '');

        $suggestions = Property::where('status', 'AVAILABLE')
            ->where(function ($q) use ($query) {
                $q->where('title', 'LIKE', "%{$query}%")
                    ->orWhere('city', 'LIKE', "%{$query}%")
                    ->orWhere('district', 'LIKE', "%{$query}%")
                    ->orWhere('address', 'LIKE', "%{$query}%");
            })
            ->select(['id', 'title', 'city', 'district', 'address', 'property_type'])
            ->limit(10)
            ->get();

        return response()->json($suggestions);
    }

    public function savedSearches(Request $request): JsonResponse
    {
        $searches = $request->user()->savedSearches()->latest()->get();

        return response()->json($searches);
    }

    public function saveSearch(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'nullable|string|max:255',
            'filters' => 'required|array',
            'notify_new' => 'boolean',
        ]);

        $search = $request->user()->savedSearches()->create($validated);

        return response()->json($search, 201);
    }

    public function deleteSavedSearch(int $id): JsonResponse
    {
        SavedSearch::findOrFail($id)->delete();

        return response()->json(['message' => 'تم حذف البحث المحفوظ']);
    }
}
