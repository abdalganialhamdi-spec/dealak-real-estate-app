import 'package:dealak_flutter/data/models/property_model.dart';

class FavoriteModel {
  final int id;
  final PropertyModel? property;
  final DateTime? createdAt;

  const FavoriteModel({required this.id, this.property, this.createdAt});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      property: json['property'] != null ? PropertyModel.fromJson(json['property']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
