import 'package:flutter/material.dart';

class CreateRequestScreen extends StatelessWidget {
  const CreateRequestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('إنشاء طلب')), body: const Center(child: Text('إنشاء طلب عقاري')));
  }
}
