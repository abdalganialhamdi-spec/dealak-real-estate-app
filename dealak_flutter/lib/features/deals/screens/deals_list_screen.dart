import 'package:flutter/material.dart';

class DealsListScreen extends StatelessWidget {
  const DealsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصفقات')),
      body: const Center(child: Text('قائمة الصفقات')),
    );
  }
}
