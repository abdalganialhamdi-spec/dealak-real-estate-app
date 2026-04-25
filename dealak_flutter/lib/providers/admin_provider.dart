import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
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
    FutureProvider.family<
      PaginatedResponse<PropertyModel>,
      Map<String, dynamic>
    >((ref, params) async {
      final repo = ref.read(adminRepositoryProvider);
      return repo.getAllProperties(params: params);
    });

final adminPendingPropertiesProvider =
    FutureProvider.family<
      PaginatedResponse<PropertyModel>,
      Map<String, dynamic>
    >((ref, params) async {
      final repo = ref.read(adminRepositoryProvider);
      return repo.getPendingProperties(params: params);
    });

final adminUsersProvider = FutureProvider.family<List, Map<String, dynamic>>((
  ref,
  params,
) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.getUsers(params: params);
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
