import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nikah_app/welcome_screen.dart'; // Adjust import based on your initial screen file location

void main() {
  testWidgets('Welcome screen renders properly smoke test', (WidgetTester tester) async {
    // Build our app widget wrapped in a MaterialApp and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Verify key elements on the Welcome Screen
    expect(find.text('NikkahLink'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });
}