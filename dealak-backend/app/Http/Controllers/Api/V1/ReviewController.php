<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Review\StoreReviewRequest;
use App\Http\Resources\ReviewResource;
use App\Models\Property;
use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function propertyReviews(int $propertyId): JsonResponse
    {
        $reviews = Review::with('user')
            ->where('property_id', $propertyId)
            ->latest()
            ->paginate(20);

        return response()->json(ReviewResource::collection($reviews));
    }

    public function store(StoreReviewRequest $request): JsonResponse
    {
        $review = Review::create([
            ...$request->validated(),
            'user_id' => $request->user()->id,
        ]);

        return response()->json([
            'message' => 'تم إضافة التقييم بنجاح',
            'review' => new ReviewResource($review->load('user')),
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $review = Review::findOrFail($id);
        $this->authorize('update', $review);

        $validated = $request->validate([
            'rating' => 'sometimes|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        $review->update($validated);

        return response()->json([
            'message' => 'تم تحديث التقييم',
            'review' => new ReviewResource($review->fresh()),
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $review = Review::findOrFail($id);
        $this->authorize('delete', $review);
        $review->delete();

        return response()->json(['message' => 'تم حذف التقييم']);
    }
}
