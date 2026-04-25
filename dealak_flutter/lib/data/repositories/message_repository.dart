import 'package:dealak_flutter/core/network/dio_client.dart';
import 'package:dealak_flutter/core/constants/api_endpoints.dart';
import 'package:dealak_flutter/data/models/conversation_model.dart';
import 'package:dealak_flutter/data/models/message_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';

class MessageRepository {
  final DioClient _dioClient;

  MessageRepository(this._dioClient);

  Future<PaginatedResponse<ConversationModel>> getConversations({
    int page = 1,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.conversations,
      queryParameters: {'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data,
      ConversationModel.fromJson,
    );
  }

  Future<Map<String, dynamic>> createConversation(
    int recipientId,
    String message, {
    int? propertyId,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.conversations,
      data: {
        'recipient_id': recipientId,
        'message': message,
        'property_id': propertyId,
      },
    );
    return {
      'conversation': ConversationModel.fromJson(response.data['conversation']),
      'message': MessageModel.fromJson(response.data['message']),
    };
  }

  Future<PaginatedResponse<MessageModel>> getMessages(
    int conversationId, {
    int page = 1,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.conversationMessages(conversationId),
      queryParameters: {'page': page},
    );
    return PaginatedResponse.fromJson(response.data, MessageModel.fromJson);
  }

  Future<MessageModel> sendMessage(
    int conversationId,
    String body, {
    String type = 'TEXT',
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.conversationMessages(conversationId),
      data: {'body': body, 'type': type},
    );
    return MessageModel.fromJson(response.data['data'] ?? response.data);
  }

  Future<void> markAsRead(int conversationId) async {
    await _dioClient.put(ApiEndpoints.conversationRead(conversationId));
  }
}
