import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/data/models/request_model.dart';
import 'package:dealak_flutter/data/models/pagination_model.dart';
import 'package:dealak_flutter/data/repositories/request_repository.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepository(ref.read(dioClientProvider));
});

final requestsProvider =
    FutureProvider<PaginatedResponse<PropertyRequestModel>>((ref) async {
      final repo = ref.read(requestRepositoryProvider);
      return repo.getRequests();
    });

final myRequestsProvider =
    FutureProvider<PaginatedResponse<PropertyRequestModel>>((ref) async {
      final repo = ref.read(requestRepositoryProvider);
      return repo.getMyRequests();
    });
