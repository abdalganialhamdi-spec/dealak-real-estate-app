<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\Deal;
use App\Models\Property;
use App\Models\User;
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
            ->when($request->search, fn($q, $search) => $q->where('first_name', 'ILIKE', "%{$search}%")->orWhere('email', 'ILIKE', "%{$search}%"))
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
