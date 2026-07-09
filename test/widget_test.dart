import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:troll_dash/game/level_progress.dart';
import 'package:troll_dash/main.dart';

void main() {
  setUp(() {
    // Keep the persisted-progress singleton hermetic between tests.
    SharedPreferences.setMockInitialValues({});
    LevelProgress.highestUnlockedLevel.value = 1;
  });

  testWidgets('opens Troll Dash and starts level one', (tester) async {
    await tester.pumpWidget(const TrollDashApp());

    expect(find.text('Troll Dash'), findsOneWidget);
    expect(find.text('Level auswählen'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Level auswählen'));
    await tester.pumpAndSettle();

    expect(find.text('Level-Auswahl'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);

    await tester.tap(find.text('Level 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // The level counter is unique to the in-game top bar; the level title
    // also appears on the level-select grid underneath, so assert on the
    // counter plus the jump control to confirm we're on the game screen.
    expect(find.text('Level 1 / 25'), findsOneWidget);
    expect(find.bySemanticsLabel('Jump'), findsOneWidget);
  });

  testWidgets(
    'home button returns from a level to the main menu',
    (tester) async {
      await tester.pumpWidget(const TrollDashApp());

      await tester.tap(find.widgetWithText(FilledButton, 'Level auswählen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Level 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.byTooltip('Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Troll Dash'), findsOneWidget);
      expect(find.text('Level auswählen'), findsOneWidget);
      expect(find.text('Level-Auswahl'), findsNothing);
    },
  );

  testWidgets('opens skin shop from main menu', (tester) async {
    await tester.pumpWidget(const TrollDashApp());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Skin-Shop'));
    await tester.pumpAndSettle();

    expect(find.text('Glücksrad'), findsOneWidget);
    expect(find.text('Classic Blue'), findsOneWidget);
    expect(find.text('Spin kaufen (5 Münzen)'), findsOneWidget);
  });
}
