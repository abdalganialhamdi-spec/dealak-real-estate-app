import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/providers/property_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/cached_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredPropertiesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('DEALAK', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: const Row(children: [Icon(Icons.search, color: Colors.grey), SizedBox(width: 12), Text('ابحث عن عقار...', style: TextStyle(color: Colors.grey))]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('العقارات المميزة', style: Theme.of(context).textTheme.headlineSmall),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: featuredAsync.when(
                  data: (properties) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: properties.length,
                    itemBuilder: (context, index) => _PropertyCard(property: properties[index]),
                  ),
                  loading: () => const LoadingWidget(),
                  error: (e, _) => AppErrorWidget(message: e.toString()),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('تصفح حسب النوع', style: Theme.of(context).textTheme.headlineSmall),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    _CategoryChip(icon: Icons.apartment, label: 'شقق', type: 'APARTMENT'),
                    _CategoryChip(icon: Icons.home, label: 'منازل', type: 'HOUSE'),
                    _CategoryChip(icon: Icons.villa, label: 'فلل', type: 'VILLA'),
                    _CategoryChip(icon: Icons.landscape, label: 'أراضي', type: 'LAND'),
                    _CategoryChip(icon: Icons.store, label: 'تجاري', type: 'COMMERCIAL'),
                    _CategoryChip(icon: Icons.business, label: 'مكاتب', type: 'OFFICE'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final dynamic property;
  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: property.images.isNotEmpty
                ? CachedImage(imageUrl: property.images.first.imageUrl, height: 140, width: 280, fit: BoxFit.cover)
                : Container(height: 140, color: Colors.grey[200], child: const Icon(Icons.image, size: 48, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.currency(property.price), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(property.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary), Text(' ${property.city}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String type;
  const _CategoryChip({required this.icon, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: AppColors.primary, size: 28)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
