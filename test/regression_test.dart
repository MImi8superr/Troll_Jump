import 'dart:math' as math;
import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:troll_dash/game/economy.dart';
import 'package:troll_dash/game/game_painter.dart';
import 'package:troll_dash/game/levels.dart';
import 'package:troll_dash/game/models.dart';
import 'package:troll_dash/screens/game_screen.dart';
import 'package:troll_dash/screens/level_select_screen.dart';

void main() {
  test(
    'GamePainter does not hang when the canvas has zero height',
    () {
      final level = buildLevels().first.copy();
      final player = Player(start: level.playerStart);
      final painter = GamePainter(
        level: level,
        player: player,
        playerColor: const Color(0xFF2563EB),
        cameraX: 0,
      );

      final recorder = PictureRecorder();
      // Before the size guard this looped forever (scale 0 -> infinite width).
      painter.paint(Canvas(recorder), const Size(400, 0));
      recorder.endRecording();
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );

  testWidgets('level tiles fit on a small phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: LevelSelectScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a lethal contact takes priority over the goal in the same frame',
    (tester) async {
      final overlappingLevel = Level(
        number: 1,
        title: 'Overlapping hazard and goal',
        width: 400,
        playerStart: Offset(64, floorY - playerSize.height),
        platforms: [
          Platform(id: 'floor', rect: const Rect.fromLTWH(0, floorY, 400, 80)),
        ],
        spikes: [
          Spike(
            id: 'lethal-goal-spike',
            rect: const Rect.fromLTWH(64, floorY - 36, 40, 36),
          ),
        ],
        goal: Goal(rect: const Rect.fromLTWH(64, floorY - 86, 54, 86)),
      );
      final nextLevel = Level(
        number: 2,
        title: 'Must stay locked this frame',
        width: 400,
        playerStart: Offset(64, floorY - playerSize.height),
        platforms: const [],
        spikes: const [],
        goal: Goal(rect: const Rect.fromLTWH(320, floorY - 86, 54, 86)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(levelsOverride: [overlappingLevel, nextLevel]),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('Level 1 / 2'), findsOneWidget);
      expect(find.text('Level 2 / 2'), findsNothing);

      // Dispose the running game ticker before the test ends.
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('a claimed rare coin never respawns on level entry', (
    tester,
  ) async {
    final level = buildLevels().first;
    GameEconomy.state.value = EconomyState(
      claimedRareCoinLevels: {level.number},
    );
    addTearDown(() {
      GameEconomy.state.value = const EconomyState();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          levelsOverride: [level],
          randomOverride: _AlwaysSpawnRandom(),
        ),
      ),
    );

    final gameCanvas = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .firstWhere((paint) => paint.painter is GamePainter);
    final painter = gameCanvas.painter! as GamePainter;
    expect(
      painter.level.coins.where((coin) => coin.id == 'rare-coin'),
      isEmpty,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('second lap survives death and manual restart clears it', (
    tester,
  ) async {
    final level = Level(
      number: 27,
      title: 'Second lap lifecycle',
      width: 650,
      playerStart: const Offset(64, floorY - playerSize.height),
      platforms: [
        Platform(
          id: 'floor',
          rect: const Rect.fromLTWH(0, floorY, 650, 80),
        ),
      ],
      spikes: [
        Spike(
          id: 'lap-two-spike',
          rect: const Rect.fromLTWH(200, floorY - 36, 40, 36),
          visible: false,
          dangerous: false,
        ),
      ],
      decoyGoal: Goal(
        rect: const Rect.fromLTWH(500, floorY - 86, 54, 86),
      ),
      goal: Goal(
        rect: const Rect.fromLTWH(500, floorY - 86, 54, 86),
        visible: false,
      ),
      traps: [
        SecondLapTrap(
          returnPosition: const Offset(64, floorY - playerSize.height),
          armSpikeIds: const ['lap-two-spike'],
        ),
      ],
    );
    GameEconomy.state.value = const EconomyState(
      claimedRareCoinLevels: {27},
    );
    addTearDown(() {
      GameEconomy.state.value = const EconomyState();
    });

    await tester.pumpWidget(
      MaterialApp(home: GameScreen(levelsOverride: [level])),
    );
    await tester.pump();

    GamePainter currentPainter() {
      final canvas = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .firstWhere((paint) => paint.painter is GamePainter);
      return canvas.painter! as GamePainter;
    }

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    var phaseActivated = false;
    for (var frame = 0; frame < 150; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      final trap = currentPainter()
          .level
          .traps
          .whereType<SecondLapTrap>()
          .single;
      if (trap.triggered) {
        phaseActivated = true;
        break;
      }
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    expect(phaseActivated, isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    var died = false;
    for (var frame = 0; frame < 80; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (currentPainter().hidePlayer) {
        died = true;
        break;
      }
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    expect(died, isTrue);

    var restored = false;
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 33));
      final painter = currentPainter();
      final trap = painter.level.traps.whereType<SecondLapTrap>().single;
      if (!painter.hidePlayer && trap.triggered) {
        restored = true;
        expect(painter.level.spikeById('lap-two-spike')!.dangerous, isTrue);
        break;
      }
    }
    expect(restored, isTrue);

    await tester.tap(find.byTooltip('Restart'));
    await tester.pump();
    final restarted = currentPainter();
    expect(
      restarted.level.traps.whereType<SecondLapTrap>().single.triggered,
      isFalse,
    );
    expect(restarted.level.decoyGoal!.visible, isTrue);
    expect(restarted.level.goal.visible, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _AlwaysSpawnRandom implements math.Random {
  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}
