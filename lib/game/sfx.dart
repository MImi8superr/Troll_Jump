import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Fire-and-forget sound effects for the game.
///
/// One [AudioPlayer] per effect is created lazily and reused, so a sound can
/// retrigger quickly without allocating. All failures are swallowed: on
/// platforms or test environments without an audio backend the game simply
/// plays silently instead of crashing.
class Sfx {
  Sfx._();

  static final ValueNotifier<bool> muted = ValueNotifier<bool>(false);

  static final Map<String, AudioPlayer> _players = {};

  static void jump() => _play('jump');
  static void boing() => _play('boing');
  static void trap() => _play('trap');
  static void death() => _play('death');
  static void goal() => _play('goal');
  static void checkpoint() => _play('checkpoint');

  static Future<void> _play(String name) async {
    if (muted.value) {
      return;
    }
    try {
      final player = _players.putIfAbsent(
        name,
        () => AudioPlayer(playerId: 'sfx-$name'),
      );
      await player.stop();
      await player.play(
        AssetSource('audio/$name.wav'),
        volume: 0.4,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // No audio backend available (e.g. widget tests): stay silent.
    }
  }
}
