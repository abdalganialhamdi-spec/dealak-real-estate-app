<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Model;
use Spatie\Sluggable\HasSlug;
use Spatie\Sluggable\SlugOptions;

class Property extends Model
{
    use HasFactory, HasSlug, SoftDeletes;

    protected $fillable = [
        'owner_id', 'agent_id', 'title', 'slug', 'description',
        'property_type', 'status', 'listing_type', 'price', 'currency',
        'area_sqm', 'bedrooms', 'bathrooms', 'floors', 'year_built',
        'address', 'city', 'district', 'latitude', 'longitude',
        'is_featured', 'is_negotiable', 'view_count',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'area_sqm' => 'decimal:2',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'is_featured' => 'boolean',
            'is_negotiable' => 'boolean',
            'view_count' => 'integer',
        ];
    }

    public function getSlugOptions(): SlugOptions
    {
        return SlugOptions::create()
            ->generateSlugsFrom('title')
            ->saveSlugsTo('slug')
            ->doNotGenerateSlugsOnUpdate();
    }

    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function agent()
    {
        return $this->belongsTo(User::class, 'agent_id');
    }

    public function images()
    {
        return $this->hasMany(PropertyImage::class)->orderBy('sort_order');
    }

    public function primaryImage()
    {
        return $this->hasOne(PropertyImage::class)->where('is_primary', true);
    }

    public function features()
    {
        return $this->hasMany(PropertyFeature::class);
    }

    public function views()
    {
        return $this->hasMany(PropertyView::class);
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function deals()
    {
        return $this->hasMany(Deal::class);
    }

    public function scopeAvailable($query)
    {
        return $query->where('status', 'AVAILABLE');
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeByType($query, string $type)
    {
        return $query->where('property_type', $type);
    }

    public function scopeByListingType($query, string $type)
    {
        return $query->where('listing_type', $type);
    }

    public function scopeInCity($query, string $city)
    {
        return $query->where('city', $city);
    }

    public function scopePriceRange($query, ?float $min, ?float $max)
    {
        return $query->when($min, fn($q) => $q->where('price', '>=', $min))
                     ->when($max, fn($q) => $q->where('price', '<=', $max));
    }

    public function averageRating(): float
    {
        return $this->reviews()->avg('rating') ?? 0;
    }
}
