// ============================================
// MamaCare KE - Widget Test Suite
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamacare_ke/ui/widgets/mamacare_logo.dart';
import 'package:mamacare_ke/ui/widgets/emergency_banner.dart';

void main() {
  testWidgets('MamaCareLogo renders brand title and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: MamaCareLogo(size: 40),
          ),
        ),
      ),
    );

    expect(find.text('MamaCare KE'), findsOneWidget);
    expect(find.text('Your pregnancy companion'), findsOneWidget);
  });

  testWidgets('MamaCareLogo.appIcon hides text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MamaCareLogo.appIcon(size: 48),
          ),
        ),
      ),
    );

    // appIcon sets showText=false, so brand text should not appear
    expect(find.text('MamaCare KE'), findsNothing);
  });

  testWidgets('EmergencyBanner renders English version correctly', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmergencyBanner(
            isSwahili: false,
            onMoreInfoPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify English text is displayed
    expect(find.text('Maternal Emergency?'), findsOneWidget);
    expect(find.text('Call 1199 (Kenya Red Cross) Toll-Free'), findsOneWidget);
    expect(find.byType(EmergencyBanner), findsOneWidget);

    // Verify the Call button is visible
    expect(find.text('Call 1199'), findsOneWidget);
    expect(tapped, isFalse);
  });

  testWidgets('EmergencyBanner renders Kiswahili version correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmergencyBanner(
            isSwahili: true,
          ),
        ),
      ),
    );

    // Verify Kiswahili text is displayed
    expect(find.text('Dharura ya Uzazi? (Emergency)'), findsOneWidget);
    expect(find.text('Piga 1199'), findsOneWidget);
  });

  testWidgets('EmergencyBanner call button exists and is tappable', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmergencyBanner(isSwahili: false),
        ),
      ),
    );

    // Find the ElevatedButton (the call 1199 button)
    final callButton = find.widgetWithText(ElevatedButton, 'Call 1199');
    expect(callButton, findsOneWidget);
  });
}
