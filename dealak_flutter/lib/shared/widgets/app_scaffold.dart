import 'package:flutter/material.dart';
import 'package:dealak_flutter/shared/widgets/app_bottom_nav.dart';
import 'package:dealak_flutter/shared/widgets/app_app_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBottomNav;
  final bool showAppBar;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBottomNav = true,
    this.showAppBar = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppAppBar(title: title ?? '', actions: actions) : null,
      body: child,
      bottomNavigationBar: showBottomNav ? const AppBottomNav() : null,
    );
  }
}
