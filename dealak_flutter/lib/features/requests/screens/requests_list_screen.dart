import 'package:flutter/material.dart';

class RequestsListScreen extends StatelessWidget {
  const RequestsListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('الطلبات')), body: const Center(child: Text('الطلبات العقارية')));
  }
}
