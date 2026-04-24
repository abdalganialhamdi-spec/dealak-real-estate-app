<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\ImageService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password as PasswordRule;

class UserController extends Controller
{
    public function __construct(private ImageService $imageService) {}

    public function show(int $id): JsonResponse
    {
        $user = User::withCount(['properties', 'reviews'])->findOrFail($id);

        return response()->json(new UserResource($user));
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'first_name' => 'sometimes|string|max:255',
            'last_name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|unique:users,phone,' . $request->user()->id,
            'bio' => 'nullable|string|max:1000',
        ]);

        $request->user()->update($validated);

        return response()->json([
            'message' => 'تم تحديث الملف الشخصي بنجاح',
            'user' => new UserResource($request->user()->fresh()),
        ]);
    }

    public function updateAvatar(Request $request): JsonResponse
    {
        $request->validate(['avatar' => 'required|image|max:2048']);

        $path = $this->imageService->uploadAvatar($request->file('avatar'), $request->user());

        $request->user()->update(['avatar_url' => $path]);

        return response()->json([
            'message' => 'تم تحديث الصورة الشخصية',
            'avatar_url' => $path,
        ]);
    }

    public function updatePassword(Request $request): JsonResponse
    {
        $request->validate([
            'current_password' => 'required|string',
            'password' => ['required', 'string', PasswordRule::min(8)->mixedCase()->numbers(), 'confirmed'],
        ]);

        if (!Hash::check($request->current_password, $request->user()->password)) {
            return response()->json(['message' => 'كلمة المرور الحالية غير صحيحة'], 422);
        }

        $request->user()->update(['password' => $request->password]);

        return response()->json(['message' => 'تم تغيير كلمة المرور بنجاح']);
    }
}
