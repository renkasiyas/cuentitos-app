import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cuentitos/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper: pump frames for a duration (works with infinite animations)
  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    final end = tester.binding.clock.now().add(duration);
    while (tester.binding.clock.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('Cuentitos E2E', () {
    testWidgets('1. cold launch shows welcome screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CuentitosApp()));

      // Pump frames (don't use pumpAndSettle — infinite animations)
      await pumpFor(tester, const Duration(seconds: 3));

      // Welcome screen should show "Cuentitos" title and "Comenzar" button
      expect(find.text('Cuentitos'), findsOneWidget);
      expect(find.text('Comenzar'), findsOneWidget);
      expect(find.text('Ya tengo cuenta'), findsOneWidget);
    });

    testWidgets('2. welcome → login → back to welcome', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CuentitosApp()));
      await pumpFor(tester, const Duration(seconds: 3));

      // Tap "Comenzar"
      await tester.tap(find.text('Comenzar'));
      await pumpFor(tester, const Duration(seconds: 2));

      // Should see login screen
      expect(find.text('Enviar enlace mágico'), findsOneWidget);
      expect(find.text('Continuar con Google'), findsOneWidget);

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
      await pumpFor(tester, const Duration(seconds: 2));

      // Should be back on welcome
      expect(find.text('Comenzar'), findsOneWidget);
    });

    testWidgets('3. login email validation', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CuentitosApp()));
      await pumpFor(tester, const Duration(seconds: 3));

      // Go to login
      await tester.tap(find.text('Comenzar'));
      await pumpFor(tester, const Duration(seconds: 2));

      // Tap send without email
      await tester.tap(find.text('Enviar enlace mágico'));
      await pumpFor(tester, const Duration(seconds: 1));

      // Error should appear
      expect(find.text('Ingresa tu correo electrónico'), findsOneWidget);
    });

    testWidgets('4. login email input works', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CuentitosApp()));
      await pumpFor(tester, const Duration(seconds: 3));

      // Go to login
      await tester.tap(find.text('Comenzar'));
      await pumpFor(tester, const Duration(seconds: 2));

      // Type an email
      final emailField = find.byType(TextField);
      expect(emailField, findsOneWidget);
      await tester.enterText(emailField, 'test@cuentitos.mx');
      await pumpFor(tester, const Duration(milliseconds: 500));

      // The text should be in the field
      expect(find.text('test@cuentitos.mx'), findsOneWidget);
    });

    testWidgets('5. animations render without crashing', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: CuentitosApp()));

      // Pump many frames to stress-test animations
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // App should still be alive
      expect(find.byType(MaterialApp), findsOneWidget);

      // Navigate to login and pump more frames
      if (find.text('Comenzar').evaluate().isNotEmpty) {
        await tester.tap(find.text('Comenzar'));
        for (int i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });
}
