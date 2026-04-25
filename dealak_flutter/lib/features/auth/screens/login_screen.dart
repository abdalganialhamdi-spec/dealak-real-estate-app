import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/validators.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';
import 'package:dealak_flutter/shared/widgets/custom_button.dart';
import 'package:dealak_flutter/shared/widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.listenManual<AuthState>(authProvider, (prev, next) {
      if (next.isAuthenticated && next.user != null) {
        final role = next.user?.role ?? '';
        if (role == 'ADMIN') {
          context.go(RouteNames.adminDashboard);
        } else {
          context.go(RouteNames.home);
        }
      } else if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: AppColors.error),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.settings_ethernet),
                    tooltip: 'إعدادات الاتصال',
                    onPressed: () => context.push(RouteNames.apiSettings),
                  ),
                ),
                const SizedBox(height: 30),
                Text('DEALAK', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 8),
                Text('منصة العقارات في سوريا', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 48),
                CustomTextField(label: 'البريد الإلكتروني', controller: _emailController, keyboardType: TextInputType.emailAddress, validator: Validators.email, prefixIcon: const Icon(Icons.email_outlined)),
                const SizedBox(height: 16),
                CustomTextField(label: 'كلمة المرور', controller: _passwordController, obscureText: true, validator: (v) => Validators.required(v, 'كلمة المرور'), prefixIcon: const Icon(Icons.lock_outlined)),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () => context.push(RouteNames.forgotPassword), child: const Text('نسيت كلمة المرور؟'))),
                const SizedBox(height: 24),
                CustomButton(label: 'تسجيل الدخول', isLoading: authState.isLoading, onPressed: _login),
                if (authState.error != null) ...[
                  const SizedBox(height: 16),
                  Text(authState.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(onPressed: () => context.push(RouteNames.register), child: const Text('إنشاء حساب جديد')),
                  const Text('ليس لديك حساب؟'),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).login(_emailController.text, _passwordController.text);
    }
  }
}