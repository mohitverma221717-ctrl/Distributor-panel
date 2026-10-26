import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopeasy_distributor/main.dart';
import 'package:shopeasy_distributor/shared/widgets/primary_button.dart';

void main() {
  testWidgets('ShopEasy app launches and displays login screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: ShopEasyDistributorApp()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Distributor Login'), findsOneWidget);
    expect(find.text('Connect  •  Supply  •  Grow'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets(
    'Tapping Login button authenticates and opens the Dashboard screen',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const ProviderScope(child: ShopEasyDistributorApp()),
      );

      await tester.pumpAndSettle();

      // Verify initial Login screen state
      expect(find.text('Distributor Login'), findsOneWidget);

      // Tap Login button
      final loginFinder = find.widgetWithText(PrimaryButton, 'Login');
      await tester.tap(loginFinder);
      await tester.pump();
      // Simulate repository login network latency (650ms)
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Verify it navigated to Dashboard screen with Ramesh Kumar and metrics
      expect(find.text('Welcome, Ramesh Kumar'), findsOneWidget);
      expect(find.text('Total Demand'), findsOneWidget);
      expect(find.text('Warehouse Stock'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();
    },
  );
}
