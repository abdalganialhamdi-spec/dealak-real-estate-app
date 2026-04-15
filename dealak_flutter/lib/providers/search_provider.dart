import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/models/search_filter_model.dart';
import 'package:dealak_flutter/data/repositories/search_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) => SearchRepository(ref.read(dioClientProvider)));

final searchFilterProvider = StateProvider<SearchFilterModel>((ref) => SearchFilterModel());

final searchResultsProvider = FutureProvider<PaginatedResponse<PropertyModel>>((ref) async {
  final filter = ref.watch(searchFilterProvider);
  final repo = ref.read(searchRepositoryProvider);
  return repo.search(filter);
});

final suggestionsProvider = FutureProvider.family<List<dynamic>, String>((ref, query) async {
  if (query.length < 2) return [];
  final repo = ref.read(searchRepositoryProvider);
  return repo.getSuggestions(query);
});
