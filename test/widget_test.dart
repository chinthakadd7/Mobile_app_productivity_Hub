// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Actify/main.dart';

void main() {
  testWidgets('App boots and navigates between tabs', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

  // Starts on Notes page (AppBar title)
  expect(find.widgetWithText(AppBar, 'Notes'), findsOneWidget);

    // Go to Reminders
    await tester.tap(find.byIcon(Icons.alarm_outlined));
    await tester.pumpAndSettle();
  expect(find.widgetWithText(AppBar, 'Reminders'), findsOneWidget);

    // Go to Timetable
    await tester.tap(find.byIcon(Icons.event_outlined));
    await tester.pumpAndSettle();
  expect(find.widgetWithText(AppBar, 'Timetable'), findsOneWidget);

    // Go to Profile
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Account Settings'), findsOneWidget);
  });
}
