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
        Schema::create('deals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained();
            $table->foreignId('buyer_id')->constrained('users');
            $table->foreignId('seller_id')->constrained('users');
            $table->foreignId('agent_id')->nullable()->constrained('users');
            $table->foreignId('request_id')->nullable()->constrained('property_requests')->nullOnDelete();
            $table->enum('deal_type', ['SALE','RENT']);
            $table->decimal('agreed_price', 15, 2);
            $table->string('currency', 3)->default('SYP');
            $table->decimal('commission_rate', 5, 2)->nullable();
            $table->decimal('commission_amount', 15, 2)->nullable();
            $table->decimal('deposit_amount', 15, 2)->nullable();
            $table->boolean('deposit_paid')->default(false);
            $table->string('rent_period')->nullable();
            $table->timestamp('signed_at')->nullable();
            $table->enum('status', ['PENDING','IN_PROGRESS','COMPLETED','CANCELLED'])->default('PENDING');
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('deals');
    }
};
