class PaymentModel {
  final int id;
  final int dealId;
  final int payerId;
  final int payeeId;
  final double amount;
  final String currency;
  final String method;
  final String status;
  final String? referenceNumber;
  final String? notes;
  final DateTime? paidAt;
  final DateTime? createdAt;

  const PaymentModel({
    required this.id,
    required this.dealId,
    required this.payerId,
    required this.payeeId,
    required this.amount,
    this.currency = 'SYP',
    required this.method,
    required this.status,
    this.referenceNumber,
    this.notes,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      dealId: json['deal_id'],
      payerId: json['payer_id'],
      payeeId: json['payee_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'SYP',
      method: json['method'] ?? 'CASH',
      status: json['status'] ?? 'PENDING',
      referenceNumber: json['reference_number'],
      notes: json['notes'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
