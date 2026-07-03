import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:troll_run/main.dart';

void main() {
  testWidgets('opens Troll Runner and starts level one', (tester) async {
    await tester.pumpWidget(const TrollRunnerApp());

    expect(find.text('Troll Runner'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Level 1 / 15'), findsOneWidget);
    expect(find.text('First Steps'), findsOneWidget);
  });
}
