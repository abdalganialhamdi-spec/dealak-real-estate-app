import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/providers/property_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/cached_image.dart';
import 'package:dealak_flutter/shared/widgets/empty_state_widget.dart';

class PropertyListScreen extends ConsumerStatefulWidget {
  const PropertyListScreen({super.key});

  @override
  ConsumerState<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends ConsumerState<PropertyListScreen> {
  final _scrollController = ScrollController();
  int _currentPage = 1;
  List<PropertyModel> _allProperties = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && _hasMore && !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    ref.invalidate(propertyProvider({'page': _currentPage}));
  }

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final params = state.uri.queryParameters;
    final propertiesAsync = ref.watch(propertyProvider(params.isEmpty ? null : params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('العقارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => context.push(RouteNames.search),
          ),
        ],
      ),
      body: propertiesAsync.when(
        data: (paginated) {
          _allProperties = paginated.data;
          _hasMore = paginated.hasMore;
          if (_allProperties.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.home_work_outlined,
              message: 'لا توجد عقارات حالياً',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              _currentPage = 1;
              ref.invalidate(propertyProvider(params.isEmpty ? null : params));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _allProperties.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _allProperties.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _PropertyListItem(property: _allProperties[index]);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'جاري تحميل العقارات...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(propertyProvider(params.isEmpty ? null : params)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.propertyCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PropertyListItem extends StatelessWidget {
  final PropertyModel property;
  const _PropertyListItem({required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.propertyDetail}/${property.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
              child: property.images.isNotEmpty
                  ? CachedImage(imageUrl: property.images.first.imageUrl, width: 120, height: 120, fit: BoxFit.cover)
                  : Container(width: 120, height: 120, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Formatters.currency(property.price), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(property.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                        Expanded(child: Text(' ${property.city}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      children: [
                        if (property.bedrooms != null) _InfoChip(icon: Icons.bed, text: '${property.bedrooms}'),
                        if (property.bathrooms != null) _InfoChip(icon: Icons.bathtub, text: '${property.bathrooms}'),
                        if (property.areaSqm != null) _InfoChip(icon: Icons.square_foot, text: Formatters.area(property.areaSqm!)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 2),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
