import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:troll_dash/game/economy.dart';
import 'package:troll_dash/game/level_progress.dart';
import 'package:troll_dash/main.dart';
import 'package:troll_dash/screens/shop_screen.dart';

void main() {
  setUp(() {
    // Keep the persisted singletons hermetic between tests.
    SharedPreferences.setMockInitialValues({});
    LevelProgress.highestUnlockedLevel.value = 1;
    GameEconomy.state.value = const EconomyState();
  });

  testWidgets('opens Troll Dash and starts level one', (tester) async {
    await tester.pumpWidget(const TrollDashApp());

    expect(find.text('Troll Dash'), findsOneWidget);
    expect(find.text('Choose Level'), findsOneWidget);
    expect(find.text('A game by Mias Ehrensperger'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Choose Level'));
    await tester.pumpAndSettle();

    expect(find.text('Level Select'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);

    await tester.tap(find.text('Level 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // The level counter is unique to the in-game top bar; the level title
    // also appears on the level-select grid underneath, so assert on the
    // counter plus the jump control to confirm we're on the game screen.
    expect(find.text('Level 1 / 29'), findsOneWidget);
    expect(find.bySemanticsLabel('Jump'), findsOneWidget);
  });

  testWidgets(
    'home button returns from a level to the main menu',
    (tester) async {
      await tester.pumpWidget(const TrollDashApp());

      await tester.tap(find.widgetWithText(FilledButton, 'Choose Level'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Level 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.byTooltip('Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Troll Dash'), findsOneWidget);
      expect(find.text('Choose Level'), findsOneWidget);
      expect(find.text('Level Select'), findsNothing);
    },
  );

  testWidgets('opens skin shop from main menu', (tester) async {
    await tester.pumpWidget(const TrollDashApp());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Skin Shop'));
    await tester.pumpAndSettle();

    // Page one hosts the wheel; the coin balance lives in the app bar.
    expect(find.text('Lucky Wheel'), findsOneWidget);
    expect(find.text('Buy a spin (5 coins)'), findsOneWidget);
    expect(find.text('0 coins'), findsOneWidget);

    // The skins sit on the second swipe page; the chevron mirrors the swipe.
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Skins'), findsOneWidget);
    expect(find.text('Classic Blue'), findsOneWidget);
  });

  testWidgets('spin wheel animates before revealing the result', (
    tester,
  ) async {
    GameEconomy.state.value = const EconomyState(coins: 5);
    await tester.pumpWidget(const MaterialApp(home: ShopScreen()));

    await tester.tap(find.text('Buy a spin (5 coins)'));
    await tester.pump();

    // The prize is applied immediately, but the text stays hidden while
    // the wheel is still spinning.
    final result = GameEconomy.state.value.lastSpinResult;
    expect(result, isNotNull);
    expect(find.text(result!), findsNothing);

    // Once the wheel has stopped, the result is revealed.
    await tester.pump(const Duration(seconds: 4));
    expect(find.text(result), findsOneWidget);
  });
}
