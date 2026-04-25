import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/providers/admin_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/cached_image.dart';

class AdminUserDetailScreen extends ConsumerWidget {
  final int userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can get the user from the list if it's already loaded, 
    // but for simplicity let's assume we might need to fetch it or pass it.
    // Here we'll just show what we have.
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المستخدم')),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            _buildUserHeader(context, ref, isDark),
            const TabBar(
              tabs: [
                Tab(text: 'العقارات'),
                Tab(text: 'الصفقات'),
                Tab(text: 'النشاط'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _UserPropertiesList(userId: userId),
                  _UserDealsList(userId: userId),
                  const Center(child: Text('قريباً: سجل النشاط')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, WidgetRef ref, bool isDark) {
    // In a real app, we might fetch the user by ID here.
    // For now, let's just show a placeholder if we don't have the user object passed.
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مستخدم #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('جاري تحميل البيانات...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserPropertiesList extends ConsumerWidget {
  final int userId;
  const _UserPropertiesList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(adminPropertiesProvider({'owner_id': userId}));

    return propertiesAsync.when(
      data: (paginated) {
        final properties = paginated.data;
        if (properties.isEmpty) {
          return const Center(child: Text('لا يوجد عقارات'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: property.images.isNotEmpty 
                  ? CachedImage(imageUrl: property.images.first.thumbnailUrl, width: 50, height: 50, borderRadius: BorderRadius.circular(4))
                  : const Icon(Icons.home),
                title: Text(property.title),
                subtitle: Text(Formatters.currency(property.price)),
                trailing: Text(Formatters.status(property.status)),
              ),
            );
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
    );
  }
}

class _UserDealsList extends ConsumerWidget {
  final int userId;
  const _UserDealsList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(adminUserDealsProvider(userId));

    return dealsAsync.when(
      data: (deals) {
        if (deals.isEmpty) {
          return const Center(child: Text('لا يوجد صفقات'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deals.length,
          itemBuilder: (context, index) {
            final deal = deals[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('صفقة #${deal.id}'),
                subtitle: Text('الحالة: ${deal.status}'),
                trailing: Text(Formatters.currency(deal.amount.toDouble())),
              ),
            );
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
    );
  }
}
