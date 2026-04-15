<?php

use App\Http\Controllers\Api\V1\AdminController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\ConversationController;
use App\Http\Controllers\Api\V1\DealController;
use App\Http\Controllers\Api\V1\FavoriteController;
use App\Http\Controllers\Api\V1\MessageController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\PropertyController;
use App\Http\Controllers\Api\V1\RequestController;
use App\Http\Controllers\Api\V1\ReviewController;
use App\Http\Controllers\Api\V1\SearchController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    Route::get('/health', function () {
        return response()->json([
            'status' => 'ok',
            'app' => 'DEALAK',
            'version' => '1.0.0',
            'timestamp' => now()->toISOString(),
        ]);
    });

    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
        Route::post('/reset-password', [AuthController::class, 'resetPassword']);

        Route::middleware('auth:sanctum')->group(function () {
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::get('/me', [AuthController::class, 'me']);
            Route::post('/refresh', [AuthController::class, 'refresh']);
        });
    });

    Route::get('/properties', [PropertyController::class, 'index']);
    Route::get('/properties/featured', [PropertyController::class, 'featured']);
    Route::get('/properties/slug/{slug}', [PropertyController::class, 'showBySlug']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/properties/my', [PropertyController::class, 'myProperties']);
        Route::post('/properties', [PropertyController::class, 'store']);
        Route::put('/properties/{id}', [PropertyController::class, 'update']);
        Route::delete('/properties/{id}', [PropertyController::class, 'destroy']);
        Route::post('/properties/{id}/images', [PropertyController::class, 'uploadImages']);
        Route::delete('/properties/{id}/images/{imageId}', [PropertyController::class, 'deleteImage']);
    });

    Route::get('/properties/{id}', [PropertyController::class, 'show']);
    Route::get('/properties/{id}/similar', [PropertyController::class, 'similar']);

    Route::get('/search', [SearchController::class, 'search']);
    Route::get('/search/nearby', [SearchController::class, 'nearby']);
    Route::get('/search/suggestions', [SearchController::class, 'suggestions']);

    Route::get('/reviews/property/{propertyId}', [ReviewController::class, 'propertyReviews']);

    Route::get('/users/{id}', [UserController::class, 'show']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/search/saved', [SearchController::class, 'saveSearch']);
        Route::get('/search/saved', [SearchController::class, 'savedSearches']);
        Route::delete('/search/saved/{id}', [SearchController::class, 'deleteSavedSearch']);

        Route::apiResource('favorites', FavoriteController::class)->except(['update', 'show']);
        Route::get('/favorites/check/{propertyId}', [FavoriteController::class, 'check']);
        Route::delete('/favorites/{propertyId}', [FavoriteController::class, 'destroy']);

        Route::get('/conversations', [ConversationController::class, 'index']);
        Route::post('/conversations', [ConversationController::class, 'store']);
        Route::get('/conversations/{id}/messages', [ConversationController::class, 'messages']);
        Route::post('/conversations/{id}/messages', [MessageController::class, 'store']);
        Route::put('/conversations/{id}/read', [ConversationController::class, 'markAsRead']);

        Route::get('/deals', [DealController::class, 'index']);
        Route::post('/deals', [DealController::class, 'store']);
        Route::get('/deals/{id}', [DealController::class, 'show']);
        Route::put('/deals/{id}', [DealController::class, 'update']);
        Route::post('/deals/{id}/payments', [DealController::class, 'recordPayment']);
        Route::get('/deals/{id}/payments', [DealController::class, 'payments']);

        Route::post('/reviews', [ReviewController::class, 'store']);
        Route::put('/reviews/{id}', [ReviewController::class, 'update']);
        Route::delete('/reviews/{id}', [ReviewController::class, 'destroy']);

        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
        Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
        Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
        Route::post('/notifications/device-token', [NotificationController::class, 'registerDeviceToken']);

        Route::get('/requests', [RequestController::class, 'index']);
        Route::post('/requests', [RequestController::class, 'store']);
        Route::put('/requests/{id}', [RequestController::class, 'update']);
        Route::delete('/requests/{id}', [RequestController::class, 'destroy']);

        Route::put('/users/profile', [UserController::class, 'updateProfile']);
        Route::post('/users/avatar', [UserController::class, 'updateAvatar']);
        Route::put('/users/password', [UserController::class, 'updatePassword']);
    });

    Route::middleware(['auth:sanctum', 'admin'])->prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminController::class, 'dashboard']);
        Route::get('/users', [AdminController::class, 'users']);
        Route::put('/users/{id}/status', [AdminController::class, 'updateUserStatus']);
        Route::get('/properties/pending', [AdminController::class, 'pendingProperties']);
        Route::put('/properties/{id}/approve', [AdminController::class, 'approveProperty']);
        Route::get('/reports', [AdminController::class, 'reports']);
    });
});
