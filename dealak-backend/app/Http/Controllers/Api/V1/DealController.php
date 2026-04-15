<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Deal\StoreDealRequest;
use App\Http\Requests\Deal\UpdateDealRequest;
use App\Http\Resources\DealCollection;
use App\Http\Resources\DealResource;
use App\Models\Deal;
use App\Services\DealService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DealController extends Controller
{
    public function __construct(private DealService $dealService) {}

    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;
        $deals = Deal::with(['property', 'buyer', 'seller', 'agent', 'payments'])
            ->where(function ($q) use ($userId) {
                $q->where('buyer_id', $userId)
                    ->orWhere('seller_id', $userId)
                    ->orWhere('agent_id', $userId);
            })
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json(new DealCollection($deals));
    }

    public function store(StoreDealRequest $request): JsonResponse
    {
        $deal = $this->dealService->createDeal($request->validated(), $request->user());

        return response()->json([
            'message' => 'تم إنشاء الصفقة بنجاح',
            'deal' => new DealResource($deal->load(['property', 'buyer', 'seller'])),
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $deal = Deal::with(['property.images', 'buyer', 'seller', 'agent', 'payments'])
            ->where('id', $id)
            ->where(function ($q) use ($request) {
                $q->where('buyer_id', $request->user()->id)
                    ->orWhere('seller_id', $request->user()->id)
                    ->orWhere('agent_id', $request->user()->id);
            })->firstOrFail();

        return response()->json(new DealResource($deal));
    }

    public function update(UpdateDealRequest $request, int $id): JsonResponse
    {
        $deal = Deal::findOrFail($id);
        $this->authorize('update', $deal);

        $deal = $this->dealService->updateDealStatus($deal, $request->validated());

        return response()->json([
            'message' => 'تم تحديث الصفقة بنجاح',
            'deal' => new DealResource($deal->fresh()),
        ]);
    }

    public function recordPayment(Request $request, int $id): JsonResponse
    {
        $deal = Deal::findOrFail($id);
        $this->authorize('update', $deal);

        $validated = $request->validate([
            'amount' => 'required|numeric|min:0',
            'method' => 'required|in:CASH,BANK_TRANSFER,CHECK,OTHER',
            'reference_number' => 'nullable|string',
            'notes' => 'nullable|string',
            'paid_at' => 'nullable|date',
        ]);

        $payment = $this->dealService->recordPayment($deal, $validated, $request->user());

        return response()->json([
            'message' => 'تم تسجيل الدفعة بنجاح',
            'payment' => $payment,
        ], 201);
    }

    public function payments(int $id): JsonResponse
    {
        $deal = Deal::findOrFail($id);
        $this->authorize('view', $deal);

        return response()->json($deal->payments()->latest()->get());
    }
}
