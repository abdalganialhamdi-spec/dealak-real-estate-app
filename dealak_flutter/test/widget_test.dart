import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/app_with_api_config.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DealakAppWithApiConfig()));
    await tester.pumpAndSettle();
    expect(find.byType(DealakAppWithApiConfig), findsOneWidget);
  });
}
