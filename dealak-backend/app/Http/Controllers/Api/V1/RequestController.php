<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Request\StoreRequestRequest;
use App\Http\Resources\PropertyRequestResource;
use App\Models\PropertyRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RequestController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $requests = PropertyRequest::where('user_id', $request->user()->id)
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json(new \App\Http\Resources\PropertyRequestCollection($requests));
    }

    public function store(StoreRequestRequest $request): JsonResponse
    {
        $propertyRequest = PropertyRequest::create([
            ...$request->validated(),
            'user_id' => $request->user()->id,
        ]);

        return response()->json([
            'message' => 'تم إنشاء الطلب بنجاح',
            'data' => new PropertyRequestResource($propertyRequest),
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $propertyRequest = PropertyRequest::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $validated = $request->validate([
            'property_type' => 'nullable|string',
            'listing_type' => 'nullable|string',
            'city' => 'nullable|string',
            'district' => 'nullable|string',
            'min_price' => 'nullable|numeric',
            'max_price' => 'nullable|numeric',
            'min_area' => 'nullable|numeric',
            'max_area' => 'nullable|numeric',
            'min_bedrooms' => 'nullable|integer',
            'max_bedrooms' => 'nullable|integer',
            'notes' => 'nullable|string',
        ]);

        $propertyRequest->update($validated);

        return response()->json([
            'message' => 'تم تحديث الطلب',
            'data' => new PropertyRequestResource($propertyRequest->fresh()),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $propertyRequest = PropertyRequest::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $propertyRequest->update(['status' => 'CANCELLED']);

        return response()->json(['message' => 'تم إلغاء الطلب']);
    }
}
