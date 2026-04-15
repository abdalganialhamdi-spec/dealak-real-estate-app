import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/utils/validators.dart';
import 'package:dealak_flutter/providers/auth_provider.dart';
import 'package:dealak_flutter/shared/widgets/custom_button.dart';
import 'package:dealak_flutter/shared/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;
  bool _isLoading = false;

  @override
  void dispose() { _emailController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نسيت كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text('أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            CustomTextField(label: 'البريد الإلكتروني', controller: _emailController, keyboardType: TextInputType.emailAddress, validator: Validators.email),
            const SizedBox(height: 24),
            CustomButton(
              label: _sent ? 'تم الإرسال' : 'إرسال رابط إعادة التعيين',
              isLoading: _isLoading,
              onPressed: _sent ? () {} : () => _sendResetLink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendResetLink() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(_emailController.text);
      setState(() => _sent = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال رابط إعادة التعيين')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
