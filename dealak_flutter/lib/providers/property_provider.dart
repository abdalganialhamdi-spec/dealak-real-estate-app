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

final propertyProvider = FutureProvider.family<PaginatedResponse<PropertyModel>, Map<String, dynamic>?>((ref, params) async {
  final repo = ref.read(propertyRepositoryProvider);
  return repo.getProperties(params: params);
});

final propertyDetailProvider = FutureProvider.family<PropertyModel, int>((ref, id) async {
  final repo = ref.read(propertyRepositoryProvider);
  return repo.getProperty(id);
});

final myPropertiesProvider = FutureProvider.family<PaginatedResponse<PropertyModel>, int>((ref, page) async {
  final repo = ref.read(propertyRepositoryProvider);
  return repo.getMyProperties(params: {'page': page});
});
