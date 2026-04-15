class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List).map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      currentPage: json['meta']?['current_page'] ?? 1,
      lastPage: json['meta']?['last_page'] ?? 1,
      perPage: json['meta']?['per_page'] ?? 20,
      total: json['meta']?['total'] ?? 0,
      hasMore: (json['meta']?['current_page'] ?? 1) < (json['meta']?['last_page'] ?? 1),
    );
  }
}
