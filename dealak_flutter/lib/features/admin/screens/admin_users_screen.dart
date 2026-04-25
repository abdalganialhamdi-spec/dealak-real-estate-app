import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/data/models/user_model.dart';
import 'package:dealak_flutter/providers/admin_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String _roleFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final params = <String, dynamic>{
      'page': 1,
      'per_page': 50,
      if (_searchController.text.isNotEmpty) 'search': _searchController.text,
      if (_roleFilter.isNotEmpty) 'role': _roleFilter,
    };
    final usersAsync = ref.watch(adminUsersProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminUsersProvider(params)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث بالاسم أو البريد...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'الكل',
                        selected: _roleFilter.isEmpty,
                        onTap: () => setState(() => _roleFilter = ''),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'مدير',
                        selected: _roleFilter == 'ADMIN',
                        onTap: () => setState(() => _roleFilter = 'ADMIN'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'وكيل',
                        selected: _roleFilter == 'AGENT',
                        onTap: () => setState(() => _roleFilter = 'AGENT'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'بائع',
                        selected: _roleFilter == 'SELLER',
                        onTap: () => setState(() => _roleFilter = 'SELLER'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'مشتري',
                        selected: _roleFilter == 'BUYER',
                        onTap: () => setState(() => _roleFilter = 'BUYER'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: usersAsync.when(
              data: (paginated) {
                final users = paginated.data;
                if (users.isEmpty) {
                  return const Center(child: Text('لا يوجد مستخدمين'));
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(adminUsersProvider(params)),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _UserCard(
                        user: user,
                        isDark: isDark,
                        onToggleStatus: () => _toggleUserStatus(user),
                        onUpdateRole: (role) => _updateUserRole(user, role),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(message: 'جاري التحميل...'),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(adminUsersProvider(params)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    try {
      await ref.read(adminRepositoryProvider).updateUserStatus(user.id, !user.isVerified);
      final params = <String, dynamic>{
        'page': 1,
        'per_page': 50,
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
        if (_roleFilter.isNotEmpty) 'role': _roleFilter,
      };
      ref.invalidate(adminUsersProvider(params));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(!user.isVerified ? 'تم تفعيل المستخدم' : 'تم تعطيل المستخدم')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _updateUserRole(UserModel user, String role) async {
    try {
      await ref.read(adminRepositoryProvider).updateUserRole(user.id, role);
      final params = <String, dynamic>{
        'page': 1,
        'per_page': 50,
        if (_searchController.text.isNotEmpty) 'search': _searchController.text,
        if (_roleFilter.isNotEmpty) 'role': _roleFilter,
      };
      ref.invalidate(adminUsersProvider(params));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث دور المستخدم بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  final VoidCallback onToggleStatus;
  final Function(String) onUpdateRole;

  const _UserCard({
    required this.user,
    required this.isDark,
    required this.onToggleStatus,
    required this.onUpdateRole,
  });

  @override
  Widget build(BuildContext context) {
    final name = user.fullName;
    final email = user.email;
    final role = user.role;
    final isActive = user.isVerified;
    final phone = user.phone ?? '';

    return InkWell(
      onTap: () => context.push('${RouteNames.adminUserDetail}/${user.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _roleColor(role).withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: _roleColor(role), fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(phone, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                initialValue: role,
                onSelected: onUpdateRole,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'ADMIN', child: Text('مدير')),
                  const PopupMenuItem(value: 'AGENT', child: Text('وكيل')),
                  const PopupMenuItem(value: 'SELLER', child: Text('بائع')),
                  const PopupMenuItem(value: 'BUYER', child: Text('مشتري')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _roleColor(role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _roleLabel(role),
                        style: TextStyle(
                            color: _roleColor(role),
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onToggleStatus,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'مفعّل' : 'معطّل',
                    style: TextStyle(
                      color: isActive ? AppColors.success : AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'ADMIN':
        return 'مدير';
      case 'AGENT':
        return 'وكيل';
      case 'SELLER':
        return 'بائع';
      default:
        return 'مشتري';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return AppColors.error;
      case 'AGENT':
        return AppColors.primary;
      case 'SELLER':
        return AppColors.secondary;
      default:
        return AppColors.accent;
    }
  }
}
