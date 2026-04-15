import 'package:flutter/material.dart';

class PropertyDetailScreen extends StatelessWidget {
  final int propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('تفاصيل العقار')), body: Center(child: Text('عقار رقم $propertyId')));
  }
}
