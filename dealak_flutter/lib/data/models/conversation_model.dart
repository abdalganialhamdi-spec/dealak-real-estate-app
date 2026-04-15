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
      id: json['id'],
      participantOne: json['participant_one'] != null ? UserModel.fromJson(json['participant_one']) : null,
      participantTwo: json['participant_two'] != null ? UserModel.fromJson(json['participant_two']) : null,
      property: json['property'] != null ? PropertyModel.fromJson(json['property']) : null,
      lastMessage: json['last_message'] != null ? MessageModel.fromJson(json['last_message']) : null,
      lastMessageAt: json['last_message_at'] != null ? DateTime.parse(json['last_message_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
