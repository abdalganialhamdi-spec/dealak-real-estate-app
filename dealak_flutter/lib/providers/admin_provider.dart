import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/data/models/deal_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/admin_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.read(dioClientProvider)),
);

final adminDashboardProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.getDashboard();
});

final adminPropertiesProvider =
    AsyncNotifierProviderFamily<AdminPropertiesNotifier, PaginatedResponse<PropertyModel>, Map<String, dynamic>>(() {
  return AdminPropertiesNotifier();
});

class AdminPropertiesNotifier extends FamilyAsyncNotifier<PaginatedResponse<PropertyModel>, Map<String, dynamic>> {
  @override
  Future<PaginatedResponse<PropertyModel>> build(Map<String, dynamic> arg) async {
    return ref.read(adminRepositoryProvider).getAllProperties(params: arg);
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    state = const AsyncLoading<PaginatedResponse<PropertyModel>>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final nextPage = currentState.currentPage + 1;
      final nextResponse = await ref.read(adminRepositoryProvider).getAllProperties(
        params: {
          ...arg,
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

final adminPendingPropertiesProvider =
    AsyncNotifierProviderFamily<AdminPendingPropertiesNotifier, PaginatedResponse<PropertyModel>, Map<String, dynamic>>(() {
  return AdminPendingPropertiesNotifier();
});

class AdminPendingPropertiesNotifier extends FamilyAsyncNotifier<PaginatedResponse<PropertyModel>, Map<String, dynamic>> {
  @override
  Future<PaginatedResponse<PropertyModel>> build(Map<String, dynamic> arg) async {
    return ref.read(adminRepositoryProvider).getPendingProperties(params: arg);
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    state = const AsyncLoading<PaginatedResponse<PropertyModel>>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final nextPage = currentState.currentPage + 1;
      final nextResponse = await ref.read(adminRepositoryProvider).getPendingProperties(
        params: {
          ...arg,
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

final adminUsersProvider =
    AsyncNotifierProviderFamily<AdminUsersNotifier, PaginatedResponse<UserModel>, Map<String, dynamic>>(() {
  return AdminUsersNotifier();
});

class AdminUsersNotifier extends FamilyAsyncNotifier<PaginatedResponse<UserModel>, Map<String, dynamic>> {
  @override
  Future<PaginatedResponse<UserModel>> build(Map<String, dynamic> arg) async {
    return ref.read(adminRepositoryProvider).getUsers(params: arg);
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    state = const AsyncLoading<PaginatedResponse<UserModel>>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final nextPage = currentState.currentPage + 1;
      final nextResponse = await ref.read(adminRepositoryProvider).getUsers(
        params: {
          ...arg,
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


final adminUserDealsProvider =
    FutureProvider.family<List<DealModel>, int>((ref, userId) async {
      final repo = ref.read(adminRepositoryProvider);
      return repo.getUserDeals(userId);
    });

final adminReportsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.getReports();
});

class AdminPropertyNotifier extends StateNotifier<AsyncValue<PropertyModel?>> {
  final AdminRepository _repository;

  AdminPropertyNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createProperty(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createProperty(data));
  }

  Future<void> updateProperty(int id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateProperty(id, data));
  }

  Future<void> deleteProperty(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteProperty(id);
      return null;
    });
  }

  Future<void> toggleFeatured(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.toggleFeatured(id);
      return null;
    });
  }

  Future<void> approveProperty(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.approveProperty(id);
      return null;
    });
  }

  Future<void> uploadImages(int propertyId, List<MultipartFile> files) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.uploadImages(propertyId, files);
      return null;
    });
  }

  Future<void> deleteImage(int propertyId, int imageId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteImage(propertyId, imageId);
      return null;
    });
  }
}

final adminPropertyProvider =
    StateNotifierProvider<AdminPropertyNotifier, AsyncValue<PropertyModel?>>((
      ref,
    ) {
      return AdminPropertyNotifier(ref.read(adminRepositoryProvider));
    });
