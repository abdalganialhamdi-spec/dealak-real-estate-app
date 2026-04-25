import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/providers/property_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/cached_image.dart';
import 'package:dealak_flutter/shared/widgets/empty_state_widget.dart';

class MyPropertiesScreen extends ConsumerStatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  ConsumerState<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends ConsumerState<MyPropertiesScreen> {
  final _scrollController = ScrollController();

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(myPropertiesProvider(null).notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final myPropertiesAsync = ref.watch(myPropertiesProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('عقاراتي')),
      body: myPropertiesAsync.when(
        data: (paginated) {
          final properties = paginated.data;
          final hasMore = paginated.hasMore;

          if (properties.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.home_work_outlined,
              message: 'لم تقم بإضافة أي عقار بعد',
              actionLabel: 'إضافة عقار',
              onAction: () => context.push(RouteNames.propertyCreate),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myPropertiesProvider(null)),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: properties.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == properties.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final property = properties[index];
                return _MyPropertyCard(property: property);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'جاري تحميل عقاراتي...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(myPropertiesProvider(null)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.propertyCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MyPropertyCard extends StatelessWidget {
  final dynamic property;
  const _MyPropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.propertyDetail}/${property.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
              child: property.images.isNotEmpty
                  ? CachedImage(imageUrl: property.images.first.imageUrl, width: 100, height: 110, fit: BoxFit.cover)
                  : Container(width: 100, height: 110, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(property.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                        _StatusBadge(status: property.status ?? 'AVAILABLE'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(Formatters.currency(property.price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('${Formatters.propertyType(property.propertyType)} • ${property.city}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (property.viewCount != null)
                          Text('${property.viewCount} مشاهدة', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(Formatters.status(status), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'AVAILABLE': return AppColors.available;
      case 'SOLD': return AppColors.sold;
      case 'PENDING': return AppColors.pending;
      case 'RESERVED': return AppColors.reserved;
      default: return AppColors.textSecondary;
    }
  }
}
