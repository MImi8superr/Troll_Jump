import 'dart:math' as math;
import 'dart:ui';

import 'models.dart';

/// The highest platform top the player can actually stand on anywhere in the
/// game. The corridor roofs (tops at y=310) exist purely to hang ceiling
/// spikes from — they are out of jump reach and must never host a coin.
const double lowestReachablePlatformTop = 340;

/// Rolls the rare bonus coin for a fresh level entry.
///
/// Returns null when the roll fails or no suitable platform exists. Only
/// solid, visible platforms that are wide enough to land on comfortably and
/// whose top the player can actually reach qualify — so the bonus is always
/// collectible.
Coin? rollRareCoin(Level level, math.Random random, {double chance = 0.08}) {
  if (random.nextDouble() >= chance) {
    return null;
  }
  final candidates = level.platforms
      .where(
        (platform) =>
            platform.solid &&
            platform.visible &&
            platform.rect.width >= 80 &&
            platform.rect.top >= lowestReachablePlatformTop,
      )
      .toList();
  if (candidates.isEmpty) {
    return null;
  }
  final platform = candidates[random.nextInt(candidates.length)];
  final x =
      platform.rect.left +
      20 +
      random.nextDouble() * (platform.rect.width - 60);
  return Coin(
    id: 'rare-coin',
    rect: Rect.fromLTWH(x, platform.rect.top - 42, 22, 22),
  );
}
