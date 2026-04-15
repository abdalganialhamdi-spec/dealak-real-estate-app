import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/favorite_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/favorite_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) => FavoriteRepository(ref.read(dioClientProvider)));

final favoritesProvider = FutureProvider<PaginatedResponse<FavoriteModel>>((ref) async {
  final repo = ref.read(favoriteRepositoryProvider);
  return repo.getFavorites();
});

final isFavoriteProvider = FutureProvider.family<bool, int>((ref, propertyId) async {
  final repo = ref.read(favoriteRepositoryProvider);
  return repo.isFavorite(propertyId);
});
