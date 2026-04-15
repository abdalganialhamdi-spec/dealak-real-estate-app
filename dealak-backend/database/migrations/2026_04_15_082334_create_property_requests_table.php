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
        Schema::create('property_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained();
            $table->enum('request_type', ['BUY','RENT','INVEST']);
            $table->enum('property_type', [
                'APARTMENT','HOUSE','VILLA','LAND',
                'COMMERCIAL','OFFICE','WAREHOUSE','FARM'
            ])->nullable();
            $table->decimal('min_price', 15, 2)->nullable();
            $table->decimal('max_price', 15, 2)->nullable();
            $table->string('currency', 3)->default('SYP');
            $table->decimal('min_area_sqm', 10, 2)->nullable();
            $table->decimal('max_area_sqm', 10, 2)->nullable();
            $table->unsignedTinyInteger('bedrooms')->nullable();
            $table->unsignedTinyInteger('bathrooms')->nullable();
            $table->string('preferred_city')->nullable();
            $table->string('preferred_district')->nullable();
            $table->text('description')->nullable();
            $table->enum('urgency', ['LOW','NORMAL','HIGH','URGENT'])->default('NORMAL');
            $table->enum('status', ['OPEN','MATCHED','CLOSED','CANCELLED'])->default('OPEN');
            $table->timestamps();

            $table->index('request_type');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('property_requests');
    }
};
