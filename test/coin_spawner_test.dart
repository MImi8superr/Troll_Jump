import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:troll_dash/game/coin_spawner.dart';
import 'package:troll_dash/game/levels.dart';

void main() {
  test('a failed roll spawns nothing', () {
    final level = buildLevels().first;
    // chance 0 can never win the roll.
    expect(rollRareCoin(level, math.Random(1), chance: 0), isNull);
  });

  test('spawned coins always float over a reachable platform', () {
    // Across every level and many seeds: the coin must sit 42px above a
    // solid, visible, wide-enough platform whose top the player can reach.
    for (final level in buildLevels()) {
      for (var seed = 0; seed < 60; seed++) {
        final coin = rollRareCoin(level, math.Random(seed), chance: 1);
        if (coin == null) {
          continue; // level without a qualifying platform
        }
        final host = level.platforms.where(
          (platform) =>
              platform.solid &&
              platform.visible &&
              (platform.rect.top - coin.rect.top - 42).abs() < 0.001 &&
              coin.rect.left >= platform.rect.left &&
              coin.rect.right <= platform.rect.right,
        );
        expect(
          host,
          isNotEmpty,
          reason:
              'level ${level.number} seed $seed: coin at ${coin.rect} has no '
              'qualifying host platform',
        );
        expect(
          coin.rect.top,
          greaterThanOrEqualTo(lowestReachablePlatformTop - 42),
          reason:
              'level ${level.number} seed $seed: coin spawned above an '
              'unreachable roof',
        );
      }
    }
  });

  test('the corridor roofs never host a coin', () {
    // Levels 22 and 25 have decorative roofs at y=310 that are out of jump
    // reach; the spawner must skip them even though they are solid and wide.
    for (final number in [22, 25]) {
      final level = buildLevels().firstWhere((level) => level.number == number);
      for (var seed = 0; seed < 200; seed++) {
        final coin = rollRareCoin(level, math.Random(seed), chance: 1)!;
        expect(
          coin.rect.top,
          isNot(closeTo(310 - 42, 0.001)),
          reason: 'level $number seed $seed spawned on a roof',
        );
      }
    }
  });
}
