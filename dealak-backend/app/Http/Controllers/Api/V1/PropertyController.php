<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Property\StorePropertyRequest;
use App\Http\Requests\Property\UpdatePropertyRequest;
use App\Http\Resources\PropertyCollection;
use App\Http\Resources\PropertyResource;
use App\Models\Property;
use App\Services\ImageService;
use App\Services\PropertyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Spatie\QueryBuilder\AllowedFilter;
use Spatie\QueryBuilder\QueryBuilder;

class PropertyController extends Controller
{
    public function __construct(
        private PropertyService $propertyService,
        private ImageService $imageService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $properties = QueryBuilder::for(Property::class)
            ->allowedFilters([
                'property_type', 'listing_type', 'city', 'district', 'status',
                AllowedFilter::range('price'),
                AllowedFilter::range('area_sqm'),
                AllowedFilter::exact('bedrooms'),
                AllowedFilter::exact('bathrooms'),
                AllowedFilter::scope('featured'),
            ])
            ->allowedSorts(['price', 'created_at', 'area_sqm', 'view_count'])
            ->allowedIncludes(['owner', 'images', 'features', 'agent'])
            ->defaultSort('-created_at')
            ->where('status', '!=', 'DRAFT')
            ->paginate($request->per_page ?? 20);

        return response()->json(new PropertyCollection($properties));
    }

    public function store(StorePropertyRequest $request): JsonResponse
    {
        $property = $this->propertyService->createProperty(
            $request->validated(),
            $request->user()
        );

        return response()->json([
            'message' => 'تم إنشاء العقار بنجاح',
            'property' => new PropertyResource($property),
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $property = Property::with(['owner', 'agent', 'images', 'features', 'reviews.user'])
            ->findOrFail($id);

        $property->increment('view_count');

        return response()->json(new PropertyResource($property));
    }

    public function showBySlug(string $slug): JsonResponse
    {
        $property = Property::with(['owner', 'agent', 'images', 'features', 'reviews.user'])
            ->where('slug', $slug)
            ->firstOrFail();

        return response()->json(new PropertyResource($property));
    }

    public function update(UpdatePropertyRequest $request, int $id): JsonResponse
    {
        $property = Property::findOrFail($id);
        $this->authorize('update', $property);

        $property = $this->propertyService->updateProperty($property, $request->validated());

        return response()->json([
            'message' => 'تم تحديث العقار بنجاح',
            'property' => new PropertyResource($property->fresh()),
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $property = Property::findOrFail($id);
        $this->authorize('delete', $property);
        $property->delete();

        return response()->json(['message' => 'تم حذف العقار بنجاح']);
    }

    public function uploadImages(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'images.*' => 'required|image|max:5120',
        ]);

        $property = Property::findOrFail($id);
        $this->authorize('update', $property);

        $images = [];
        foreach ($request->file('images', []) as $file) {
            $images[] = $this->imageService->uploadPropertyImage($file, $property);
        }

        return response()->json([
            'message' => 'تم رفع الصور بنجاح',
            'images' => $images,
        ], 201);
    }

    public function deleteImage(int $id, int $imageId): JsonResponse
    {
        $property = Property::findOrFail($id);
        $this->authorize('update', $property);

        $image = $property->images()->findOrFail($imageId);
        $this->imageService->deletePropertyImage($image);

        return response()->json(['message' => 'تم حذف الصورة بنجاح']);
    }

    public function featured(): JsonResponse
    {
        $properties = Property::with(['owner', 'images'])
            ->featured()
            ->available()
            ->inRandomOrder()
            ->limit(10)
            ->get();

        return response()->json([
            'data' => PropertyResource::collection($properties),
            'meta' => [
                'total' => $properties->count(),
                'type' => 'featured',
            ],
        ]);
    }

    public function myProperties(Request $request): JsonResponse
    {
        $properties = QueryBuilder::for(Property::class)
            ->where('owner_id', $request->user()->id)
            ->allowedFilters(['property_type', 'listing_type', 'status'])
            ->allowedSorts(['price', 'created_at'])
            ->defaultSort('-created_at')
            ->paginate($request->per_page ?? 20);

        return response()->json(new PropertyCollection($properties));
    }

    public function similar(int $id): JsonResponse
    {
        $property = Property::findOrFail($id);

        $similar = Property::with(['owner', 'images'])
            ->where('id', '!=', $id)
            ->where('property_type', $property->property_type)
            ->where('city', $property->city)
            ->where('status', 'AVAILABLE')
            ->when($property->listing_type, fn($q) => $q->where('listing_type', $property->listing_type))
            ->limit(6)
            ->get();

        return response()->json([
            'data' => PropertyResource::collection($similar),
            'meta' => [
                'total' => $similar->count(),
                'type' => 'similar',
                'reference_id' => $id,
            ],
        ]);
    }
}
