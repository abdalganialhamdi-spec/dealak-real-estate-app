import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/app_with_api_config.dart';

void main() {
  runApp(const ProviderScope(child: DealakAppWithApiConfig()));
}
