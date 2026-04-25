import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/message_model.dart';

class ConversationModel {
  final int id;
  final UserModel? participantOne;
  final UserModel? participantTwo;
  final PropertyModel? property;
  final MessageModel? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  const ConversationModel({
    required this.id,
    this.participantOne,
    this.participantTwo,
    this.property,
    this.lastMessage,
    this.lastMessageAt,
    this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      participantOne: json['participant_one'] is Map ? UserModel.fromJson(json['participant_one'] as Map<String, dynamic>) : null,
      participantTwo: json['participant_two'] is Map ? UserModel.fromJson(json['participant_two'] as Map<String, dynamic>) : null,
      property: json['property'] is Map ? PropertyModel.fromJson(json['property'] as Map<String, dynamic>) : null,
      lastMessage: json['last_message'] is Map ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>) : null,
      lastMessageAt: json['last_message_at'] != null ? DateTime.tryParse(json['last_message_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
