<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('properties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users');
            $table->foreignId('agent_id')->nullable()->constrained('users');
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->enum('property_type', [
                'APARTMENT','HOUSE','VILLA','LAND',
                'COMMERCIAL','OFFICE','WAREHOUSE','FARM'
            ]);
            $table->enum('status', [
                'AVAILABLE','SOLD','RENTED','PENDING','RESERVED','DRAFT'
            ])->default('AVAILABLE');
            $table->enum('listing_type', [
                'SALE','RENT_MONTHLY','RENT_YEARLY','RENT_DAILY'
            ]);
            $table->decimal('price', 15, 2);
            $table->string('currency', 3)->default('SYP');
            $table->decimal('area_sqm', 10, 2)->nullable();
            $table->unsignedTinyInteger('bedrooms')->nullable();
            $table->unsignedTinyInteger('bathrooms')->nullable();
            $table->unsignedTinyInteger('floors')->nullable();
            $table->unsignedSmallInteger('year_built')->nullable();
            $table->string('address')->nullable();
            $table->string('city');
            $table->string('district')->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_negotiable')->default(true);
            $table->unsignedInteger('view_count')->default(0);
            $table->softDeletes();
            $table->timestamps();

            $table->index('property_type');
            $table->index('status');
            $table->index('listing_type');
            $table->index('price');
            $table->index('city');
            $table->index('is_featured');
            $table->index(['status', 'listing_type']);
            $table->index(['city', 'district']);
            $table->fullText(['title', 'description']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('properties');
    }
};
