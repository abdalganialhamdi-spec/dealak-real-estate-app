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
            'image_url' => url(Storage::disk('public')->url($path)),
            'thumbnail_url' => url(Storage::disk('public')->url($thumbPath)),
            'is_primary' => $property->images()->count() === 0,
            'sort_order' => $property->images()->count(),
        ]);
    }

    public function deletePropertyImage(PropertyImage $image): void
    {
        $image->delete();
    }

    public function uploadAvatar(UploadedFile $file, User $user): string
    {
        $path = $file->store("avatars/{$user->id}", 'public');
        return url(Storage::disk('public')->url($path));
    }
}
