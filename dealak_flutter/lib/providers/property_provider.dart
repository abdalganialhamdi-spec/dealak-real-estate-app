import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/property_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) => PropertyRepository(ref.read(dioClientProvider)));

final featuredPropertiesProvider = FutureProvider<List<PropertyModel>>((ref) async {
  final repo = ref.read(propertyRepositoryProvider);
  return repo.getFeatured();
});

final propertiesProvider = AsyncNotifierProviderFamily<PropertiesNotifier, PaginatedResponse<PropertyModel>, Map<String, dynamic>?>(() {
  return PropertiesNotifier();
});

class PropertiesNotifier extends FamilyAsyncNotifier<PaginatedResponse<PropertyModel>, Map<String, dynamic>?> {
  @override
  Future<PaginatedResponse<PropertyModel>> build(Map<String, dynamic>? arg) async {
    return ref.read(propertyRepositoryProvider).getProperties(params: arg);
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    // Use copyWithPrevious to keep existing data while loading
    state = const AsyncLoading<PaginatedResponse<PropertyModel>>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final nextPage = currentState.currentPage + 1;
      final nextResponse = await ref.read(propertyRepositoryProvider).getProperties(
        params: {
          ...?arg,
          'page': nextPage,
        },
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

final propertyDetailProvider = FutureProvider.family<PropertyModel, int>((ref, id) async {
  final repo = ref.read(propertyRepositoryProvider);
  return repo.getProperty(id);
});

final myPropertiesProvider = AsyncNotifierProviderFamily<MyPropertiesNotifier, PaginatedResponse<PropertyModel>, Map<String, dynamic>?>(() {
  return MyPropertiesNotifier();
});

class MyPropertiesNotifier extends FamilyAsyncNotifier<PaginatedResponse<PropertyModel>, Map<String, dynamic>?> {
  @override
  Future<PaginatedResponse<PropertyModel>> build(Map<String, dynamic>? arg) async {
    return ref.read(propertyRepositoryProvider).getMyProperties(params: arg);
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    state = const AsyncLoading<PaginatedResponse<PropertyModel>>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final nextPage = currentState.currentPage + 1;
      final nextResponse = await ref.read(propertyRepositoryProvider).getMyProperties(
        params: {
          ...?arg,
          'page': nextPage,
        },
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
}
