import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/utils/validators.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';
import 'package:dealak_flutter/shared/widgets/custom_button.dart';
import 'package:dealak_flutter/shared/widgets/custom_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'BUYER';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(label: 'الاسم الأول', controller: _firstNameController, validator: (v) => Validators.required(v, 'الاسم الأول'), prefixIcon: const Icon(Icons.person_outlined)),
              const SizedBox(height: 16),
              CustomTextField(label: 'الاسم الأخير', controller: _lastNameController, validator: (v) => Validators.required(v, 'الاسم الأخير'), prefixIcon: const Icon(Icons.person_outlined)),
              const SizedBox(height: 16),
              CustomTextField(label: 'البريد الإلكتروني', controller: _emailController, keyboardType: TextInputType.emailAddress, validator: Validators.email, prefixIcon: const Icon(Icons.email_outlined)),
              const SizedBox(height: 16),
              CustomTextField(label: 'رقم الهاتف', controller: _phoneController, keyboardType: TextInputType.phone, validator: Validators.phone, prefixIcon: const Icon(Icons.phone)),
              const SizedBox(height: 16),
              CustomTextField(label: 'كلمة المرور', controller: _passwordController, obscureText: true, validator: Validators.password, prefixIcon: const Icon(Icons.lock_outlined)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'نوع الحساب', prefixIcon: Icon(Icons.badge_outlined)),
                items: const [
                  DropdownMenuItem(value: 'BUYER', child: Text('مشتري/مستأجر')),
                  DropdownMenuItem(value: 'SELLER', child: Text('بائع/مالك')),
                  DropdownMenuItem(value: 'AGENT', child: Text('وسيط عقاري')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 24),
              CustomButton(label: 'إنشاء حساب', isLoading: authState.isLoading, onPressed: _register),
              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Text(authState.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 16),
              TextButton(onPressed: () => context.pop(), child: const Text('لديك حساب؟ تسجيل الدخول')),
            ],
          ),
        ),
      ),
    );
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).register({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
      });
    }
  }
}
