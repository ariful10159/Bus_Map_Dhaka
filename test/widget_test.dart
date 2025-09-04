// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bus_map/main.dart';

void main() {
  testWidgets('OpenStreetMap loads and marker is visible', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    // Check for map title
    expect(find.text('OpenStreetMap Example'), findsOneWidget);
    // Check for marker icon
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });
}
