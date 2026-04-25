<?php

namespace App\Services;

use App\Models\PropertyImage;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver as GdDriver;

class ImageService
{
    public function uploadPropertyImage(UploadedFile $file, $property): PropertyImage
    {
        $manager = new ImageManager(new GdDriver());

        $path = $file->store("properties/{$property->id}", 'public');

        $image = $manager->read($file);
        $image->scale(width: 400);
        $thumbnail = $image->toWebp(80);

        $thumbPath = "properties/{$property->id}/thumbs/" . Str::uuid() . '.webp';
        Storage::disk('public')->put($thumbPath, $thumbnail->toString());

        return $property->images()->create([
            'image_url' => Storage::disk('public')->url($path),
            'thumbnail_url' => Storage::disk('public')->url($thumbPath),
            'is_primary' => $property->images()->count() === 0,
            'sort_order' => $property->images()->count(),
        ]);
    }

    public function deletePropertyImage(PropertyImage $image): void
    {
        $imageUrl = $image->image_url;
        $thumbUrl = $image->thumbnail_url;

        if ($imageUrl) {
            $path = str_replace('/storage/', '', parse_url($imageUrl, PHP_URL_PATH) ?? '');
            if ($path && Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);
            }
        }

        if ($thumbUrl) {
            $thumbPath = str_replace('/storage/', '', parse_url($thumbUrl, PHP_URL_PATH) ?? '');
            if ($thumbPath && Storage::disk('public')->exists($thumbPath)) {
                Storage::disk('public')->delete($thumbPath);
            }
        }

        $image->delete();
    }

    public function uploadAvatar(UploadedFile $file, User $user): string
    {
        $path = $file->store("avatars/{$user->id}", 'public');
        return Storage::disk('public')->url($path);
    }
}
