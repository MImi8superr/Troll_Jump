import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:troll_run/main.dart';

void main() {
  testWidgets('opens Troll Runner and starts level one', (tester) async {
    await tester.pumpWidget(const TrollRunnerApp());

    expect(find.text('Troll Runner'), findsOneWidget);
    expect(find.text('Level auswählen'), findsOneWidget);
    expect(find.text('Skin-Shop'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Level auswählen'));
    await tester.pumpAndSettle();

    expect(find.text('Level-Auswahl'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);

    await tester.tap(find.text('Level 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Level 1 / 15'), findsOneWidget);
    expect(find.text('First Steps'), findsOneWidget);
  });

  testWidgets('opens skin shop from main menu', (tester) async {
    await tester.pumpWidget(const TrollRunnerApp());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Skin-Shop'));
    await tester.pumpAndSettle();

    expect(find.text('Glücksrad'), findsOneWidget);
    expect(find.text('Classic Blue'), findsOneWidget);
    expect(find.text('Spin kaufen (5 Münzen)'), findsOneWidget);
  });
}
