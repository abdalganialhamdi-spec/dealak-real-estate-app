<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\FavoriteResource;
use App\Models\Favorite;
use App\Models\Property;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $favorites = Favorite::with('property.owner', 'property.images')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json(FavoriteResource::collection($favorites));
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate(['property_id' => 'required|exists:properties,id']);

        $favorite = Favorite::firstOrCreate([
            'user_id' => $request->user()->id,
            'property_id' => $request->property_id,
        ]);

        return response()->json([
            'message' => 'تمت الإضافة للمفضلة',
            'favorite' => new FavoriteResource($favorite),
        ], 201);
    }

    public function destroy(Request $request, int $propertyId): JsonResponse
    {
        Favorite::where('user_id', $request->user()->id)
            ->where('property_id', $propertyId)
            ->delete();

        return response()->json(['message' => 'تمت الإزالة من المفضلة']);
    }

    public function check(Request $request, int $propertyId): JsonResponse
    {
        $isFavorite = Favorite::where('user_id', $request->user()->id)
            ->where('property_id', $propertyId)
            ->exists();

        return response()->json(['is_favorite' => $isFavorite]);
    }
}
