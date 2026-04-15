import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  user?.firstName.substring(0, 1) ?? '?',
                  style: const TextStyle(fontSize: 32, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.fullName ?? 'مستخدم', style: Theme.of(context).textTheme.headlineMedium),
              Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ListTile(leading: const Icon(Icons.edit), title: const Text('تعديل الملف الشخصي'), trailing: const Icon(Icons.chevron_left), onTap: () {}),
              ListTile(leading: const Icon(Icons.home_work_outlined), title: const Text('عقاراتي'), trailing: const Icon(Icons.chevron_left), onTap: () {}),
              ListTile(leading: const Icon(Icons.handshake_outlined), title: const Text('صفقاتي'), trailing: const Icon(Icons.chevron_left), onTap: () {}),
              ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('الإشعارات'), trailing: const Icon(Icons.chevron_left), onTap: () {}),
              ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('الإعدادات'), trailing: const Icon(Icons.chevron_left), onTap: () {}),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
