import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/data/models/payment_model.dart';

class DealModel {
  final int id;
  final PropertyModel? property;
  final UserModel? buyer;
  final UserModel? seller;
  final UserModel? agent;
  final double amount;
  final String currency;
  final double commission;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;
  final double totalPaid;
  final List<PaymentModel> payments;
  final DateTime? createdAt;

  const DealModel({
    required this.id,
    this.property,
    this.buyer,
    this.seller,
    this.agent,
    required this.amount,
    this.currency = 'SYP',
    this.commission = 0,
    required this.status,
    this.startDate,
    this.endDate,
    this.notes,
    this.totalPaid = 0,
    this.payments = const [],
    this.createdAt,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      id: json['id'],
      property: json['property'] != null ? PropertyModel.fromJson(json['property']) : null,
      buyer: json['buyer'] != null ? UserModel.fromJson(json['buyer']) : null,
      seller: json['seller'] != null ? UserModel.fromJson(json['seller']) : null,
      agent: json['agent'] != null ? UserModel.fromJson(json['agent']) : null,
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'SYP',
      commission: (json['commission'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      notes: json['notes'],
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      payments: json['payments'] != null
          ? (json['payments'] as List).map((e) => PaymentModel.fromJson(e)).toList()
          : [],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
