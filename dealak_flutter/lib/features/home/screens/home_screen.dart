import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/providers/property_provider.dart';
import 'package:dealak_flutter/providers/theme_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/cached_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredPropertiesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(featuredPropertiesProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, isDark),
                const SizedBox(height: 20),
                _buildSearchBar(context),
                const SizedBox(height: 20),
                _buildFilterChips(context),
                const SizedBox(height: 28),
                _buildSectionTitle(
                  context,
                  'العقارات المميزة',
                  onSeeAll: () => context.push(RouteNames.propertyList),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 280,
                  child: featuredAsync.when(
                    data: (properties) {
                      if (properties.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد عقارات مميزة',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: properties.length,
                        itemBuilder: (context, index) =>
                            _PremiumPropertyCard(property: properties[index]),
                      );
                    },
                    loading: () => const LoadingWidget(),
                    error: (e, _) => AppErrorWidget(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(featuredPropertiesProvider),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _buildSectionTitle(context, 'تصفح حسب النوع'),
                const SizedBox(height: 14),
                _buildCategories(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'DEALAK',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : AppColors.textSecondary,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(RouteNames.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings_ethernet, size: 20),
            tooltip: 'إعدادات الاتصال',
            onPressed: () => context.push(RouteNames.apiSettings),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push(RouteNames.search),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Text(
                'ابحث عن عقار...',
                style: TextStyle(color: AppColors.textHint, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.tune, color: AppColors.primary, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _QuickFilterChip(label: 'بيع', type: 'SALE', color: AppColors.sale),
          const SizedBox(width: 8),
          _QuickFilterChip(
            label: 'إيجار',
            type: 'RENT_MONTHLY',
            color: AppColors.rent,
          ),
          const SizedBox(width: 8),
          _QuickFilterChip(
            label: 'إيجار يومي',
            type: 'RENT_DAILY',
            color: AppColors.dailyRent,
          ),
          const SizedBox(width: 8),
          _QuickFilterChip(
            label: 'شقق',
            type: 'APARTMENT',
            color: AppColors.accent,
          ),
          const SizedBox(width: 8),
          _QuickFilterChip(
            label: 'فلل',
            type: 'VILLA',
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CategoryItem(icon: Icons.apartment, label: 'شقق', type: 'APARTMENT'),
          _CategoryItem(icon: Icons.home, label: 'منازل', type: 'HOUSE'),
          _CategoryItem(icon: Icons.villa, label: 'فلل', type: 'VILLA'),
          _CategoryItem(icon: Icons.landscape, label: 'أراضي', type: 'LAND'),
          _CategoryItem(icon: Icons.store, label: 'تجاري', type: 'COMMERCIAL'),
          _CategoryItem(icon: Icons.business, label: 'مكاتب', type: 'OFFICE'),
        ],
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final String type;
  final Color color;
  const _QuickFilterChip({
    required this.label,
    required this.type,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('${RouteNames.propertyList}?listing_type=$type'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PremiumPropertyCard extends StatelessWidget {
  final PropertyModel property;
  const _PremiumPropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.propertyDetail}/${property.id}'),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: property.images.isNotEmpty
                      ? CachedImage(
                          imageUrl: property.images.first.imageUrl,
                          height: 150,
                          width: 260,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      Formatters.currency(property.price),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.city}${property.district != null ? ' - ${property.district}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (property.bedrooms != null) ...[
                        _InfoBadge(
                          icon: Icons.bed,
                          value: '${property.bedrooms}',
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (property.bathrooms != null) ...[
                        _InfoBadge(
                          icon: Icons.bathtub,
                          value: '${property.bathrooms}',
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (property.areaSqm != null) ...[
                        _InfoBadge(
                          icon: Icons.square_foot,
                          value: Formatters.area(property.areaSqm!),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  const _InfoBadge({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String type;
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () =>
            context.push('${RouteNames.propertyList}?property_type=$type'),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
