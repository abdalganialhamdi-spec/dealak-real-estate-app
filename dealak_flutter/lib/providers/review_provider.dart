import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/review_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/review_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.read(dioClientProvider));
});

final propertyReviewsProvider = FutureProvider.family<PaginatedResponse<ReviewModel>, int>((ref, propertyId) async {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.getPropertyReviews(propertyId);
});