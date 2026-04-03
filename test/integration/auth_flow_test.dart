import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cuentitos/app.dart';

void main() {
  testWidgets('app renders without crashing', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const ProviderScope(child: CuentitosApp()));
      await tester.pump();
      // App should render — the exact screen depends on auth state
      expect(find.byType(CuentitosApp), findsOneWidget);
    });
  });
}
