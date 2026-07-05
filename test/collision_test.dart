import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:troll_run/game/collision.dart';
import 'package:troll_run/game/models.dart';

void main() {
  group('spikeHitsPlayer (triangular hitbox)', () {
    // Up-spike: 40 wide, apex at top-center, base along the bottom.
    final upSpike = Spike(id: 's', rect: const Rect.fromLTWH(100, 200, 40, 36));

    test('player standing on the base is hit', () {
      // A player rect overlapping the wide bottom of the triangle.
      final player = const Rect.fromLTWH(108, 220, 34, 20);
      expect(spikeHitsPlayer(upSpike, player), isTrue);
    });

    test('player in the empty corner beside the tip is NOT hit', () {
      // Top-left corner of the bounding box, where the triangle is absent.
      final player = const Rect.fromLTWH(96, 198, 12, 12);
      expect(spikeHitsPlayer(upSpike, player), isFalse);
    });

    test('player far away is not hit', () {
      final player = const Rect.fromLTWH(300, 200, 34, 46);
      expect(spikeHitsPlayer(upSpike, player), isFalse);
    });

    test('down-spike hits a player pushed up into its tip', () {
      final downSpike = Spike(
        id: 'd',
        rect: const Rect.fromLTWH(100, 100, 42, 38),
        direction: SpikeDirection.down,
      );
      // Player centered under the downward apex.
      final player = const Rect.fromLTWH(112, 128, 20, 20);
      expect(spikeHitsPlayer(downSpike, player), isTrue);
    });
  });
}
