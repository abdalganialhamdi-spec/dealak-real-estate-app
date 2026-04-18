import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/providers/admin_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/cached_image.dart';

class AdminPropertiesScreen extends ConsumerStatefulWidget {
  const AdminPropertiesScreen({super.key});

  @override
  ConsumerState<AdminPropertiesScreen> createState() => _AdminPropertiesScreenState();
}

class _AdminPropertiesScreenState extends ConsumerState<AdminPropertiesScreen> {
  String _searchQuery = '';
  String _statusFilter = '';
  String _typeFilter = '';
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final params = <String, dynamic>{
      'page': _currentPage,
      'per_page': 20,
    };
    if (_searchQuery.isNotEmpty) params['q'] = _searchQuery;
    if (_statusFilter.isNotEmpty) params['status'] = _statusFilter;
    if (_typeFilter.isNotEmpty) params['property_type'] = _typeFilter;

    final propertiesAsync = ref.watch(adminPropertiesProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العقارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminPropertiesProvider(params)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildFilterChips(isDark),
          Expanded(
            child: propertiesAsync.when(
              data: (paginated) {
                final properties = paginated.data;
                if (properties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('لا توجد عقارات', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.invalidate(adminPropertiesProvider(params)),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: properties.length,
                    itemBuilder: (context, index) => _PropertyListItem(
                      property: properties[index],
                      isDark: isDark,
                      onEdit: () => context.push('${RouteNames.adminPropertyForm}/${properties[index].id}'),
                      onDelete: () => _confirmDelete(properties[index]),
                      onToggleFeatured: () => _toggleFeatured(properties[index]),
                    ),
                  ),
                );
              },
              loading: () => const LoadingWidget(message: 'جاري التحميل...'),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(adminPropertiesProvider(params)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('${RouteNames.adminPropertyForm}/new'),
        icon: const Icon(Icons.add),
        label: const Text('إضافة عقار'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'ابحث عن عقار...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: isDark ? AppColors.surfaceDark : Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusChip('الكل', '', isDark),
            const SizedBox(width: 8),
            _buildStatusChip('متاح', 'AVAILABLE', isDark),
            const SizedBox(width: 8),
            _buildStatusChip('مباع', 'SOLD', isDark),
            const SizedBox(width: 8),
            _buildStatusChip('مؤجر', 'RENTED', isDark),
            const SizedBox(width: 8),
            _buildStatusChip('قيد المراجعة', 'PENDING', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, bool isDark) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() => _statusFilter = selected ? value : ''),
      backgroundColor: isDark ? AppColors.cardDark : Colors.grey[100],
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black)),
    );
  }

  Future<void> _confirmDelete(PropertyModel property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف العقار "${property.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminPropertyProvider.notifier).deleteProperty(property.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف العقار بنجاح')));
        ref.invalidate(adminPropertiesProvider({}));
      }
    }
  }

  Future<void> _toggleFeatured(PropertyModel property) async {
    await ref.read(adminPropertyProvider.notifier).toggleFeatured(property.id);
    if (mounted) {
      ref.invalidate(adminPropertiesProvider({}));
    }
  }
}

class _PropertyListItem extends StatelessWidget {
  final PropertyModel property;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFeatured;

  const _PropertyListItem({
    required this.property,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFeatured,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return AppColors.available;
      case 'SOLD':
        return AppColors.sold;
      case 'RENTED':
        return AppColors.rent;
      case 'PENDING':
        return AppColors.pending;
      case 'RESERVED':
        return AppColors.reserved;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (property.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedImage(imageUrl: property.images.first.imageUrl, width: double.infinity, height: 150, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(property.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(property.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(Formatters.status(property.status), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(Formatters.currency(property.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('${property.city}${property.district != null ? ' - ${property.district}' : ''}', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (property.bedrooms != null) ...[
                      Icon(Icons.bed, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${property.bedrooms} غرفة', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    ],
                    if (property.bathrooms != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.bathtub, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${property.bathrooms} حمام', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    ],
                    if (property.areaSqm != null) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.square_foot, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${property.areaSqm} م²', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (property.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(4)),
                        child: const Text('مميز', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.star_border), onPressed: onToggleFeatured, color: property.isFeatured ? AppColors.secondary : null),
                    IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                    IconButton(icon: const Icon(Icons.delete), onPressed: onDelete, color: AppColors.error),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
