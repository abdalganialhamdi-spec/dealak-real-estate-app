import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/deal_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/deal_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final dealRepositoryProvider = Provider<DealRepository>((ref) => DealRepository(ref.read(dioClientProvider)));

final dealsProvider = FutureProvider<PaginatedResponse<DealModel>>((ref) async {
  final repo = ref.read(dealRepositoryProvider);
  return repo.getDeals();
});

final dealDetailProvider = FutureProvider.family<DealModel, int>((ref, id) async {
  final repo = ref.read(dealRepositoryProvider);
  return repo.getDeal(id);
});
