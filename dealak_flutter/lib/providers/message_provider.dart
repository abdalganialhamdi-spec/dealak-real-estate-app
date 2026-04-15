import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/conversation_model.dart';
import 'package:dealak_flutter/data/models/message_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/message_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) => MessageRepository(ref.read(dioClientProvider)));

final conversationsProvider = FutureProvider<PaginatedResponse<ConversationModel>>((ref) async {
  final repo = ref.read(messageRepositoryProvider);
  return repo.getConversations();
});

final messagesProvider = FutureProvider.family<PaginatedResponse<MessageModel>, int>((ref, conversationId) async {
  final repo = ref.read(messageRepositoryProvider);
  return repo.getMessages(conversationId);
});
