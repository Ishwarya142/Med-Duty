import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:medduty/features/onboarding/onboarding_screen.dart';
import 'package:medduty/providers/location_provider.dart';

void main() {
  const widths = [320.0, 360.0, 375.0, 390.0, 412.0, 430.0];

  testWidgets('OnboardingScreen renders 3 pages without overflow on all screen sizes',
      (WidgetTester tester) async {
    for (final width in widths) {
      tester.view.physicalSize = Size(width * 2.0, 800 * 2.0);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
          child: MaterialApp(
            home: OnboardingScreen(key: ValueKey(width)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check title on first page
      expect(find.text("Find Duties Near You"), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify Next button works
      final nextButton = find.byType(ElevatedButton);
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Check title on second page
      expect(find.text("Find Healthcare Jobs"), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
