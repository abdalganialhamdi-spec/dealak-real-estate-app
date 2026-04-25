import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/conversation_model.dart';
import 'package:dealak_flutter/data/models/message_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/message_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) => MessageRepository(ref.read(dioClientProvider)));

final conversationsProvider = AsyncNotifierProvider<ConversationsNotifier, PaginatedResponse<ConversationModel>>(() {
  return ConversationsNotifier();
});

class ConversationsNotifier extends AsyncNotifier<PaginatedResponse<ConversationModel>> {
  @override
  Future<PaginatedResponse<ConversationModel>> build() async {
    return ref.read(messageRepositoryProvider).getConversations();
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    state = const AsyncLoading<PaginatedResponse<ConversationModel>>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final nextPage = currentState.currentPage + 1;
      final nextResponse = await ref.read(messageRepositoryProvider).getConversations(
        page: nextPage,
      );

      return PaginatedResponse(
        data: [...currentState.data, ...nextResponse.data],
        currentPage: nextResponse.currentPage,
        lastPage: nextResponse.lastPage,
        perPage: nextResponse.perPage,
        total: nextResponse.total,
        hasMore: nextResponse.hasMore,
      );
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final messagesProvider = AsyncNotifierProviderFamily<MessagesNotifier, PaginatedResponse<MessageModel>, int>(() {
  return MessagesNotifier();
});

class MessagesNotifier extends FamilyAsyncNotifier<PaginatedResponse<MessageModel>, int> {
  @override
  Future<PaginatedResponse<MessageModel>> build(int arg) async {
    return ref.read(messageRepositoryProvider).getMessages(arg);
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    state = const AsyncLoading<PaginatedResponse<MessageModel>>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final nextPage = currentState.currentPage + 1;
      final nextResponse = await ref.read(messageRepositoryProvider).getMessages(
        arg,
        page: nextPage,
      );

      return PaginatedResponse(
        data: [...currentState.data, ...nextResponse.data],
        currentPage: nextResponse.currentPage,
        lastPage: nextResponse.lastPage,
        perPage: nextResponse.perPage,
        total: nextResponse.total,
        hasMore: nextResponse.hasMore,
      );
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }
}

