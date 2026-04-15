import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/shared/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: const [
                  _OnboardingPage(icon: Icons.home_work, title: 'ابحث عن عقارك', description: 'اكتشف آلاف العقارات المتاحة في جميع أنحاء سوريا'),
                  _OnboardingPage(icon: Icons.chat, title: 'تواصل مباشرة', description: 'تحدث مع المالك أو الوسيط مباشرة عبر المحادثات الفورية'),
                  _OnboardingPage(icon: Icons.handshake, title: 'أتمم الصفقة', description: 'أنجز صفقتك العقارية بأمان وشفافية عبر منصة DEALAK'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomButton(
                label: _currentPage == 2 ? 'ابدأ الآن' : 'التالي',
                onPressed: () {
                  if (_currentPage == 2) {
                    context.go(RouteNames.login);
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: () => context.go(RouteNames.login), child: const Text('تخطي')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingPage({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: AppColors.primary),
          const SizedBox(height: 32),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          Text(description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
