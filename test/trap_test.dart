import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:troll_run/game/levels.dart';
import 'package:troll_run/game/models.dart';

void main() {
  group('FakeGoalTrap (level 17)', () {
    Level level17() =>
        buildLevels().firstWhere((level) => level.number == 17).copy();

    test('touching the decoy springs the trap', () {
      final level = level17();
      final decoy = level.decoyGoal!;
      final player = Player(
        start: Offset(decoy.rect.left, floorY - playerSize.height),
      );

      expect(level.goal.visible, isFalse);
      for (final trap in level.traps) {
        trap.update(level, player, 1 / 60);
      }

      expect(decoy.visible, isFalse);
      expect(level.goal.visible, isTrue);
      final revealed = level.spikeById('fake-goal-spike-1')!;
      expect(revealed.visible, isTrue);
      expect(revealed.dangerous, isTrue);
    });

    test('sneaking past the decoy also reveals the real goal', () {
      final level = level17();
      final decoy = level.decoyGoal!;
      final player = Player(
        start: Offset(decoy.rect.right + 60, floorY - playerSize.height),
      );

      for (final trap in level.traps) {
        trap.update(level, player, 1 / 60);
      }

      expect(decoy.visible, isFalse);
      expect(level.goal.visible, isTrue);
    });
  });

  group('ChasingSpikeTrap (level 16)', () {
    test('spike chases the player once woken and respects its bounds', () {
      final level =
          buildLevels().firstWhere((level) => level.number == 16).copy();
      final trap = level.traps.whereType<ChasingSpikeTrap>().single;
      final spike = level.spikeById(trap.spikeId)!;
      final startLeft = spike.rect.left;

      // Player before the trigger line: the spike stays parked.
      final farPlayer = Player(
        start: Offset(200, floorY - playerSize.height),
      );
      trap.update(level, farPlayer, 1 / 60);
      expect(spike.rect.left, startLeft);

      // Player past the trigger line: the spike slides toward them.
      final closePlayer = Player(
        start: Offset(trap.triggerX + 10, floorY - playerSize.height),
      );
      trap.update(level, closePlayer, 0.5);
      expect(trap.triggered, isTrue);
      expect(spike.rect.left, lessThan(startLeft));

      // Long chase toward a player parked left of minX: clamps at minX.
      for (var i = 0; i < 200; i++) {
        trap.update(level, closePlayer, 0.1);
      }
      expect(spike.rect.left, greaterThanOrEqualTo(trap.minX));
    });
  });

  group('checkpoints', () {
    test('spawn position stands on the floor at the flag', () {
      final checkpoint = Checkpoint(
        id: 'cp',
        rect: const Rect.fromLTWH(600, floorY - 58, 34, 58),
      );
      final spawn = checkpoint.spawnPosition;
      expect(spawn.dy, floorY - playerSize.height);
      expect(spawn.dx, 600 + (34 - playerSize.width) / 2);
    });

    test('levels 13-15 and 17 have a checkpoint', () {
      final levels = buildLevels();
      for (final number in [13, 14, 15, 17]) {
        final level = levels.firstWhere((level) => level.number == number);
        expect(level.checkpoints, isNotEmpty, reason: 'level $number');
      }
    });
  });

  group('level data sanity', () {
    test('all levels are internally consistent', () {
      final levels = buildLevels();
      expect(levels.length, 17);

      for (final level in levels) {
        // The goal must sit inside the level bounds.
        expect(
          level.goal.rect.right,
          lessThanOrEqualTo(level.width),
          reason: 'goal out of bounds in level ${level.number}',
        );

        // Object ids must be unique so trap lookups are unambiguous.
        final ids = [
          ...level.platforms.map((platform) => platform.id),
          ...level.spikes.map((spike) => spike.id),
          ...level.checkpoints.map((checkpoint) => checkpoint.id),
        ];
        expect(
          ids.toSet().length,
          ids.length,
          reason: 'duplicate object id in level ${level.number}',
        );

        // The player must start above standable ground.
        final startRect = level.playerStart & playerSize;
        final grounded = level.platforms.any(
          (platform) =>
              platform.solid &&
              platform.rect.top >= startRect.bottom - 1 &&
              startRect.right > platform.rect.left &&
              startRect.left < platform.rect.right,
        );
        expect(
          grounded,
          isTrue,
          reason: 'player starts over a pit in level ${level.number}',
        );
      }
    });
  });
}
