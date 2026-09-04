import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('Field Intelligence App smoke test', (WidgetTester tester) async {
    // Provide a taller test viewport so screens mount without constraint errors
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const FieldIntelligenceApp());
    await tester.pump();

    // Verify key titles exist
    expect(find.text('FIELD INTELLIGENCE'), findsOneWidget);
    expect(find.text('Plant Catalog'), findsOneWidget);
    expect(find.text('Ask AI Guide'), findsOneWidget);
  });
}
