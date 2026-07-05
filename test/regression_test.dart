import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:troll_run/game/game_painter.dart';
import 'package:troll_run/game/levels.dart';
import 'package:troll_run/game/models.dart';
import 'package:troll_run/screens/level_select_screen.dart';

void main() {
  test('GamePainter does not hang when the canvas has zero height', () {
    final level = buildLevels().first.copy();
    final player = Player(start: level.playerStart);
    final painter = GamePainter(level: level, player: player, cameraX: 0);

    final recorder = PictureRecorder();
    // Before the size guard this looped forever (scale 0 -> infinite width).
    painter.paint(Canvas(recorder), const Size(400, 0));
    recorder.endRecording();
  }, timeout: const Timeout(Duration(seconds: 10)));

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
}
