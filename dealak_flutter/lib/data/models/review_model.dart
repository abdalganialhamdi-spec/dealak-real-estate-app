import 'package:dealak_flutter/data/models/user_model.dart';

class ReviewModel {
  final int id;
  final UserModel? user;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  const ReviewModel({required this.id, this.user, required this.rating, this.comment, this.createdAt});

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
