<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\PropertyResource;
use App\Http\Resources\UserResource;
use App\Models\Deal;
use App\Models\Property;
use App\Models\User;
use App\Services\ImageService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function dashboard(): JsonResponse
    {
        return response()->json([
            'users_count' => User::count(),
            'properties_count' => Property::count(),
            'available_properties' => Property::where('status', 'AVAILABLE')->count(),
            'deals_count' => Deal::count(),
            'active_deals' => Deal::where('status', 'IN_PROGRESS')->count(),
            'total_revenue' => Deal::where('status', 'COMPLETED')->sum('amount'),
            'pending_properties' => Property::where('status', 'PENDING')->count(),
            'recent_users' => UserResource::collection(User::latest()->limit(5)->get()),
            'recent_properties' => Property::with('owner')->latest()->limit(5)->get(),
        ]);
    }

    public function users(Request $request): JsonResponse
    {
        $users = User::query()
            ->when($request->search, function ($q, $search) {
                $q->where(function ($query) use ($search) {
                    $query->where('first_name', 'LIKE', "%{$search}%")
                        ->orWhere('email', 'LIKE', "%{$search}%");
                });
            })
            ->when($request->role, fn($q, $role) => $q->where('role', $role))
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json(UserResource::collection($users));
    }

    public function updateUserStatus(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate(['is_active' => 'required|boolean']);

        $user = User::findOrFail($id);
        $user->update($validated);

        return response()->json([
            'message' => $validated['is_active'] ? 'تم تفعيل المستخدم' : 'تم تعطيل المستخدم',
            'user' => new UserResource($user),
        ]);
    }

    public function allProperties(Request $request): JsonResponse
    {
        $properties = Property::with(['owner', 'images'])
            ->when($request->search, function ($q, $search) {
                $q->where(function ($query) use ($search) {
                    $query->where('title', 'LIKE', "%{$search}%")
                        ->orWhere('city', 'LIKE', "%{$search}%")
                        ->orWhere('district', 'LIKE', "%{$search}%");
                });
            })
            ->when($request->status, fn($q, $status) => $q->where('status', $status))
            ->when($request->property_type, fn($q, $type) => $q->where('property_type', $type))
            ->when($request->listing_type, fn($q, $type) => $q->where('listing_type', $type))
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json(new \App\Http\Resources\PropertyCollection($properties));
    }

    public function storeProperty(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'property_type' => 'required|string|in:APARTMENT,HOUSE,VILLA,LAND,COMMERCIAL,OFFICE,WAREHOUSE,FARM',
            'listing_type' => 'required|string|in:SALE,RENT_MONTHLY,RENT_YEARLY,RENT_DAILY',
            'price' => 'required|numeric|min:0',
            'currency' => 'nullable|string|in:SYP,USD,EUR',
            'area_sqm' => 'nullable|numeric',
            'bedrooms' => 'nullable|integer',
            'bathrooms' => 'nullable|integer',
            'floors' => 'nullable|integer',
            'year_built' => 'nullable|integer',
            'address' => 'nullable|string',
            'city' => 'required|string',
            'district' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_negotiable' => 'boolean',
            'is_featured' => 'boolean',
            'status' => 'nullable|string|in:AVAILABLE,PENDING,SOLD,RESERVED,DRAFT',
        ]);

        $validated['owner_id'] = $request->user()->id;
        $validated['currency'] = $validated['currency'] ?? 'SYP';
        $validated['status'] = $validated['status'] ?? 'AVAILABLE';

        $property = Property::create($validated);

        return response()->json([
            'message' => 'تم إضافة العقار بنجاح',
            'property' => new PropertyResource($property->fresh()),
        ], 201);
    }

    public function updateProperty(Request $request, int $id): JsonResponse
    {
        $property = Property::findOrFail($id);

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'property_type' => 'sometimes|string|in:APARTMENT,HOUSE,VILLA,LAND,COMMERCIAL,OFFICE,WAREHOUSE,FARM',
            'listing_type' => 'sometimes|string|in:SALE,RENT_MONTHLY,RENT_YEARLY,RENT_DAILY',
            'price' => 'sometimes|numeric|min:0',
            'currency' => 'nullable|string|in:SYP,USD,EUR',
            'area_sqm' => 'nullable|numeric',
            'bedrooms' => 'nullable|integer',
            'bathrooms' => 'nullable|integer',
            'floors' => 'nullable|integer',
            'year_built' => 'nullable|integer',
            'address' => 'nullable|string',
            'city' => 'sometimes|string',
            'district' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_negotiable' => 'boolean',
            'is_featured' => 'boolean',
            'status' => 'nullable|string|in:AVAILABLE,PENDING,SOLD,RESERVED,DRAFT',
        ]);

        $property->update($validated);

        return response()->json([
            'message' => 'تم تحديث العقار بنجاح',
            'property' => new PropertyResource($property->fresh()),
        ]);
    }

    public function destroyProperty(int $id): JsonResponse
    {
        $property = Property::findOrFail($id);
        $property->delete();

        return response()->json(['message' => 'تم حذف العقار بنجاح']);
    }

    public function uploadPropertyImages(Request $request, ImageService $imageService, int $id): JsonResponse
    {
        $request->validate([
            'images' => 'required|array|min:1',
            'images.*' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
        ]);

        $property = Property::findOrFail($id);
        $uploadedImages = [];

        foreach ($request->file('images') as $file) {
            $uploadedImages[] = $imageService->uploadPropertyImage($file, $property);
        }

        return response()->json([
            'message' => 'تم رفع الصور بنجاح',
            'images' => $uploadedImages,
        ]);
    }

    public function deletePropertyImage(int $id, int $imageId): JsonResponse
    {
        $property = Property::findOrFail($id);
        $image = $property->images()->findOrFail($imageId);
        $image->delete();

        return response()->json(['message' => 'تم حذف الصورة بنجاح']);
    }

    public function toggleFeatured(int $id): JsonResponse
    {
        $property = Property::findOrFail($id);
        $property->update(['is_featured' => !$property->is_featured]);

        return response()->json([
            'message' => $property->is_featured ? 'تم إضافة العقار للمميزة' : 'تم إزالة العقار من المميزة',
            'is_featured' => $property->is_featured,
        ]);
    }

    public function pendingProperties(): JsonResponse
    {
        $properties = Property::with('owner')
            ->where('status', 'PENDING')
            ->latest()
            ->paginate(20);

        return response()->json($properties);
    }

    public function approveProperty(int $id): JsonResponse
    {
        $property = Property::findOrFail($id);
        $property->update(['status' => 'AVAILABLE']);

        return response()->json(['message' => 'تم قبول العقار']);
    }

    public function reports(): JsonResponse
    {
        $monthlyDeals = Deal::selectRaw("DATE_TRUNC('month', created_at) as month, COUNT(*) as count, SUM(amount) as total")
            ->groupByRaw("DATE_TRUNC('month', created_at)")
            ->orderByDesc('month')
            ->limit(12)
            ->get();

        $propertiesByCity = Property::selectRaw('city, COUNT(*) as count')
            ->groupBy('city')
            ->orderByDesc('count')
            ->limit(10)
            ->get();

        $propertiesByType = Property::selectRaw('property_type, COUNT(*) as count')
            ->groupBy('property_type')
            ->orderByDesc('count')
            ->get();

        return response()->json([
            'monthly_deals' => $monthlyDeals,
            'properties_by_city' => $propertiesByCity,
            'properties_by_type' => $propertiesByType,
        ]);
    }
}
