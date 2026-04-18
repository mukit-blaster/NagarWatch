// This is a basic Flutter widget test for NagarWatch.
//
// To run: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nagarwatch/features/authentication/providers/auth_provider.dart';
import 'package:nagarwatch/core/constants/app_colors.dart';

void main() {
  group('NagarWatch App Tests', () {
    testWidgets('App loads without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('NagarWatch'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('NagarWatch'), findsOneWidget);
    });

    test('AppColors constants are defined', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.accent, isNotNull);
      expect(AppColors.danger, isNotNull);
    });

    test('AuthProvider initializes with unauthenticated state', () {
      final auth = AuthProvider();
      expect(auth.isLoggedIn, false);
      expect(auth.isLoading, false);
      expect(auth.error, null);
    });
  });
}
