import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/review_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/review_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.read(dioClientProvider));
});

final propertyReviewsProvider = AsyncNotifierProviderFamily<PropertyReviewsNotifier, PaginatedResponse<ReviewModel>, int>(() {
  return PropertyReviewsNotifier();
});

class PropertyReviewsNotifier extends FamilyAsyncNotifier<PaginatedResponse<ReviewModel>, int> {
  @override
  Future<PaginatedResponse<ReviewModel>> build(int arg) async {
    return ref.read(reviewRepositoryProvider).getPropertyReviews(arg);
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    state = const AsyncLoading<PaginatedResponse<ReviewModel>>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final nextPage = currentState.currentPage + 1;
      final nextResponse = await ref.read(reviewRepositoryProvider).getPropertyReviews(
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