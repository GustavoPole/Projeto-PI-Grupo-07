// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projeto_pi/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app has the dietHub logo text.
    expect(find.text('dietHub'), findsOneWidget);
    expect(find.text('0'), findsNothing);

    // Tap the 'Entrar' button and trigger a frame.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify that it shows the snackbar for empty fields.
    expect(find.text('Preencha e-mail e senha.'), findsOneWidget);
  });
}
