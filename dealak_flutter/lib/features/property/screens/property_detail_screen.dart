import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/providers/property_provider.dart';
import 'package:dealak_flutter/providers/favorite_provider.dart';
import 'package:dealak_flutter/providers/message_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/cached_image.dart';
import 'package:dealak_flutter/shared/widgets/price_display.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final int propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyDetailProvider(propertyId));

    return propertyAsync.when(
      data: (property) => _PropertyDetailView(property: property),
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const LoadingWidget(message: 'جاري تحميل تفاصيل العقار...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('تفاصيل العقار')),
        body: AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(propertyDetailProvider(propertyId)),
        ),
      ),
    );
  }
}

class _PropertyDetailView extends ConsumerStatefulWidget {
  final PropertyModel property;
  const _PropertyDetailView({required this.property});

  @override
  ConsumerState<_PropertyDetailView> createState() =>
      _PropertyDetailViewState();
}

class _PropertyDetailViewState extends ConsumerState<_PropertyDetailView> {
  int _currentImageIndex = 0;

  Future<void> _contactOwner(
    BuildContext context,
    PropertyModel property,
  ) async {
    try {
      final repo = ref.read(messageRepositoryProvider);
      final result = await repo.createConversation(
        property.owner!.id,
        'مرحباً، أنا مهتم بعقارك: ${property.title}',
        propertyId: property.id,
      );
      final conversation = result['conversation'];
      if (mounted) {
        context.push('${RouteNames.chat}/${conversation.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final isFavAsync = ref.watch(isFavoriteProvider(property.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(icon: Icon(Icons.share), onPressed: () {}),
              isFavAsync.when(
                data: (isFav) => IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: () async {
                    final repo = ref.read(favoriteRepositoryProvider);
                    try {
                      if (isFav) {
                        await repo.removeFavorite(property.id);
                      } else {
                        await repo.addFavorite(property.id);
                      }
                      ref.invalidate(isFavoriteProvider(property.id));
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                ),
                loading: () => const IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: null,
                ),
                error: (_, __) => const IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: null,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: property.images.isNotEmpty
                  ? Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 300,
                            viewportFraction: 1.0,
                            onPageChanged: (index, _) =>
                                setState(() => _currentImageIndex = index),
                          ),
                          items: property.images
                              .map(
                                (img) => CachedImage(
                                  imageUrl: img.imageUrl,
                                  width: double.infinity,
                                  height: 300,
                                  fit: BoxFit.cover,
                                ),
                              )
                              .toList(),
                        ),
                        if (property.images.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1} / ${property.images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      _StatusChip(status: property.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PriceDisplay(
                    price: property.price,
                    currency: property.currency,
                    listingType: property.listingType,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [property.address, property.district, property.city]
                              .whereType<String>()
                              .where((s) => s.isNotEmpty)
                              .join('، '),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.propertyType(property.propertyType)} • ${Formatters.listingType(property.listingType)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const Divider(height: 32),
                  _InfoRow(property: property),
                  const SizedBox(height: 16),
                  if (property.description != null &&
                      property.description!.isNotEmpty) ...[
                    Text(
                      'الوصف',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (property.features.isNotEmpty) ...[
                    Text(
                      'المميزات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.features
                          .map(
                            (f) => Chip(
                              label: Text(
                                f.name +
                                    (f.value != null ? ': ${f.value}' : ''),
                              ),
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (property.owner != null) ...[
                    const Divider(height: 32),
                    Text(
                      'المالك',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _OwnerCard(owner: property.owner!),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: property.owner != null
                      ? () => _contactOwner(context, property)
                      : null,
                  icon: const Icon(Icons.chat),
                  label: const Text('تواصل مع المالك'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('${RouteNames.propertyDetail}/${property.id}'),
                icon: const Icon(Icons.phone),
                label: const Text('اتصال'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        Formatters.status(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'AVAILABLE':
        return AppColors.available;
      case 'SOLD':
        return AppColors.sold;
      case 'PENDING':
        return AppColors.pending;
      case 'RESERVED':
        return AppColors.reserved;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final PropertyModel property;
  const _InfoRow({required this.property});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (property.areaSqm != null)
          _InfoItem(
            icon: Icons.square_foot,
            label: Formatters.area(property.areaSqm!),
          ),
        if (property.bedrooms != null)
          _InfoItem(icon: Icons.bed, label: '${property.bedrooms} غرف'),
        if (property.bathrooms != null)
          _InfoItem(icon: Icons.bathtub, label: '${property.bathrooms} حمام'),
        if (property.floors != null)
          _InfoItem(icon: Icons.layers, label: '${property.floors} طوابق'),
        _InfoItem(
          icon: Icons.visibility,
          label: '${property.viewCount} مشاهدة',
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final dynamic owner;
  const _OwnerCard({required this.owner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              owner.firstName?.substring(0, 1) ?? '?',
              style: const TextStyle(color: AppColors.primary, fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner.fullName ?? 'مالك',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (owner.propertiesCount != null)
                  Text(
                    '${owner.propertiesCount} عقار',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (owner.isVerified)
            const Icon(Icons.verified, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}
