import 'package:dealak_flutter/data/models/property_model.dart';

class FavoriteModel {
  final int id;
  final PropertyModel? property;
  final DateTime? createdAt;

  const FavoriteModel({required this.id, this.property, this.createdAt});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      property: json['property'] is Map ? PropertyModel.fromJson(json['property'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
    );
  }
}
