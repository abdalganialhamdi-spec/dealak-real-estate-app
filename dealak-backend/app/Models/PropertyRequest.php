<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PropertyRequest extends Model
{
    use HasFactory;

    protected $table = 'property_requests';

    protected $fillable = [
        'user_id', 'property_type', 'listing_type', 'city', 'district',
        'min_price', 'max_price', 'min_area', 'max_area',
        'min_bedrooms', 'max_bedrooms', 'notes', 'status',
    ];

    protected function casts(): array
    {
        return [
            'min_price' => 'decimal:2',
            'max_price' => 'decimal:2',
            'min_area' => 'decimal:2',
            'max_area' => 'decimal:2',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'ACTIVE');
    }
}
