import 'package:dealak_flutter/data/models/user_model.dart';

class MessageModel {
  final int id;
  final int conversationId;
  final UserModel? sender;
  final String body;
  final String type;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    this.sender,
    required this.body,
    this.type = 'TEXT',
    this.metadata,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      sender: json['sender'] != null ? UserModel.fromJson(json['sender']) : null,
      body: json['body'] ?? '',
      type: json['type'] ?? 'TEXT',
      metadata: json['metadata'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
