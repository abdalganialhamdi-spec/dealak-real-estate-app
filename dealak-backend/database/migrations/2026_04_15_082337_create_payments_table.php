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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('deal_id')->constrained();
            $table->foreignId('payer_id')->constrained('users');
            $table->foreignId('payee_id')->constrained('users');
            $table->enum('payment_type', ['DEPOSIT','INSTALLMENT','FULL','COMMISSION','RENT']);
            $table->decimal('amount', 15, 2);
            $table->string('currency', 3)->default('SYP');
            $table->enum('payment_method', ['CASH','BANK_TRANSFER','CHECK','ELECTRONIC']);
            $table->string('transaction_reference')->nullable();
            $table->unsignedInteger('installment_number')->nullable();
            $table->unsignedInteger('total_installments')->nullable();
            $table->enum('status', ['PENDING','COMPLETED','FAILED','REFUNDED'])->default('PENDING');
            $table->timestamp('paid_at')->nullable();
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
        Schema::dropIfExists('payments');
    }
};
