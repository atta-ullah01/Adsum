import 'package:flutter_test/flutter_test.dart';
import 'package:adsum/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App starts (Smoke Test)', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AdsumApp()));
    expect(find.text('ADSUM'), findsOneWidget);
  });
}
