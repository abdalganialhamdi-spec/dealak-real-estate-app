import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/providers/theme_provider.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المظهر', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('فاتح'),
                    secondary: const Icon(Icons.light_mode),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (v) => ref.read(themeModeProvider.notifier).setTheme(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('داكن'),
                    secondary: const Icon(Icons.dark_mode),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (v) => ref.read(themeModeProvider.notifier).setTheme(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('تلقائي'),
                    secondary: const Icon(Icons.brightness_auto),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (v) => ref.read(themeModeProvider.notifier).setTheme(v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('عام', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('الإشعارات'),
                    subtitle: const Text('تلقي إشعارات التطبيق'),
                    secondary: const Icon(Icons.notifications_outlined),
                    value: true,
                    onChanged: (v) {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('اللغة'),
                    subtitle: const Text('العربية'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('حول التطبيق'),
                    subtitle: const Text('DEALAK v1.0.0'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'DEALAK',
                        applicationVersion: '1.0.0',
                        children: [const Text('منصة عقارية سورية')],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('الحساب', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('تغيير كلمة المرور'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push(RouteNames.forgotPassword),
                  ),
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('إعدادات الاتصال'),
                    subtitle: const Text('تغيير عنوان السيرفر'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => context.push(RouteNames.apiSettings),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: const Text('حذف الحساب', style: TextStyle(color: AppColors.error)),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => _showDeleteConfirmDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text('هذا الإجراء لا يمكن التراجع عنه. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
