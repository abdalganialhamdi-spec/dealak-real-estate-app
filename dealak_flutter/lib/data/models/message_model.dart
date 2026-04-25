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
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      conversationId: json['conversation_id'] is int ? json['conversation_id'] : int.tryParse('${json['conversation_id']}') ?? 0,
      sender: json['sender'] is Map ? UserModel.fromJson(json['sender'] as Map<String, dynamic>) : null,
      body: json['body'] ?? '',
      type: json['type'] ?? 'TEXT',
      metadata: json['metadata'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
