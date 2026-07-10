import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/coin_spawner.dart';
import '../game/collision.dart';
import '../game/economy.dart';
import '../game/game_painter.dart';
import '../game/game_stats.dart';
import '../game/level_progress.dart';
import '../game/levels.dart';
import '../game/models.dart';
import '../game/sfx.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.initialLevelIndex = 0,
    this.levelsOverride,
    this.randomOverride,
  });

  final int initialLevelIndex;

  @visibleForTesting
  final List<Level>? levelsOverride;

  @visibleForTesting
  final math.Random? randomOverride;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const double _moveSpeed = 260;
  static const double _acceleration = 1900;
  static const double _gravity = 1450;
  static const double _jumpVelocity = -570;
  static const double _maxFallSpeed = 900;

  /// Grace period after walking off a ledge during which a jump still works.
  static const double _coyoteDuration = 0.1;

  /// Rising speed a jump is cut to when the jump button is released early.
  static const double _jumpCutVelocity = -300;

  static const double _deathDuration = 0.55;

  /// The level whose goal leads to the fake win screen instead of the next
  /// level (the original "final" level, before the bonus levels were added).
  static const int _fakeWinLevelIndex = 14;

  late final List<Level> _levels;
  late final Ticker _ticker;
  late Level _level;
  late Player _player;

  int _levelIndex = 0;
  bool _leftHeld = false;
  bool _rightHeld = false;
  bool _transitioning = false;
  double _jumpBuffer = 0;
  double _coyoteTimer = 0;
  bool _jumpHeld = false;
  bool _jumpCuttable = false;
  int _deathsThisLevel = 0;
  int _triggeredTrapCount = 0;
  double _deathTimer = 0;
  double _deathElapsed = 0;
  Offset? _checkpointSpawn;
  String? _checkpointId;
  bool _secondLapActive = false;
  Duration? _lastTick;
  bool _hasLoadedLevel = false;

  /// Spot of this level entry's rare coin; null once collected (or when the
  /// entry roll came up empty).
  Rect? _rareCoinRect;

  final List<DeathParticle> _particles = [];
  late final math.Random _random;
  final FocusNode _focusNode = FocusNode(debugLabel: 'game-keyboard');

  @override
  void initState() {
    super.initState();
    _random = widget.randomOverride ?? math.Random();
    _levels = widget.levelsOverride ?? buildLevels();
    _loadLevel(widget.initialLevelIndex.clamp(0, _levels.length - 1));
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadLevel(int index, {bool keepCheckpoint = false}) {
    final restoreCheckpoint = keepCheckpoint && index == _levelIndex;
    final restoreSecondLap = restoreCheckpoint && _secondLapActive;
    final freshEntry = !_hasLoadedLevel || index != _levelIndex;
    if (index != _levelIndex) {
      _deathsThisLevel = 0;
    }
    if (!restoreCheckpoint) {
      _checkpointSpawn = null;
      _checkpointId = null;
      _secondLapActive = false;
    }

    _levelIndex = index;
    _hasLoadedLevel = true;
    _level = _levels[index].copy();
    // The rare coin is rolled once per level entry until it has been claimed.
    // Deaths and manual restarts keep the same result and position; once the
    // coin has paid out, later entries into this level cannot spawn it again.
    if (GameEconomy.hasClaimedRareCoin(_level.number)) {
      _rareCoinRect = null;
    } else if (freshEntry) {
      _rareCoinRect = rollRareCoin(_level, _random)?.rect;
    }
    if (_rareCoinRect != null) {
      _level.coins.add(Coin(id: 'rare-coin', rect: _rareCoinRect!));
    }
    _player = Player(start: _level.playerStart);
    var secondLapRestored = false;
    if (restoreSecondLap) {
      for (final trap in _level.traps.whereType<SecondLapTrap>()) {
        trap.restoreSecondLap(_level);
        _player.position = trap.returnPosition;
        _player.velocity = Offset.zero;
        _player.onGround = false;
        _player.groundPlatformId = null;
        _checkpointSpawn = null;
        _checkpointId = null;
        secondLapRestored = true;
        break;
      }
      if (!secondLapRestored) {
        _secondLapActive = false;
      }
    }
    if (!secondLapRestored && restoreCheckpoint && _checkpointSpawn != null) {
      _player.position = _checkpointSpawn!;
      for (final checkpoint in _level.checkpoints) {
        if (checkpoint.id == _checkpointId) {
          checkpoint.reached = true;
        }
      }
    }

    _leftHeld = false;
    _rightHeld = false;
    _jumpBuffer = 0;
    _coyoteTimer = 0;
    _jumpCuttable = false;
    _deathTimer = 0;
    _triggeredTrapCount = _level.traps
        .where((trap) => trap.triggered)
        .length;
    _particles.clear();
  }

  void _tick(Duration elapsed) {
    final previous = _lastTick;
    _lastTick = elapsed;
    if (previous == null || _transitioning) {
      return;
    }

    final rawDt = (elapsed - previous).inMicroseconds / 1000000;
    final dt = rawDt.clamp(0.0, 1 / 30).toDouble();
    if (dt <= 0) {
      return;
    }

    setState(() {
      _updateGame(dt);
    });
  }

  void _updateGame(double dt) {
    if (_deathTimer > 0) {
      _deathTimer -= dt;
      _deathElapsed += dt;
      for (final particle in _particles) {
        particle.update(dt);
      }
      _particles.removeWhere((particle) => particle.life <= 0);
      if (_deathTimer <= 0) {
        _loadLevel(_levelIndex, keepCheckpoint: true);
      }
      return;
    }

    _jumpBuffer = math.max(0, _jumpBuffer - dt);

    _applyHorizontalInput(dt);
    _tryStartJump();

    for (final trap in _level.traps) {
      trap.update(_level, _player, dt);
    }
    if (!_secondLapActive &&
        _level.traps.whereType<SecondLapTrap>().any(
          (trap) => trap.triggered,
        )) {
      _secondLapActive = true;
      // The second lap always restarts at its explicit return position. An
      // earlier first-lap checkpoint must not override that after a death.
      _checkpointSpawn = null;
      _checkpointId = null;
    }
    _level.updateObjects(dt, _player);

    _player.velocity = Offset(
      _player.velocity.dx,
      math.min(_maxFallSpeed, _player.velocity.dy + _gravity * dt),
    );

    _moveHorizontally(dt);
    _moveVertically(dt);

    if (_player.onGround) {
      _coyoteTimer = _coyoteDuration;
    } else {
      _coyoteTimer = math.max(0, _coyoteTimer - dt);
    }

    _updateCheckpointsAndZones();
    _notifyTrapSounds();
    _checkHazardsAndBounds();
    // A lethal contact wins frame resolution. Do not bank a coin or finish
    // the level from the same player position after death has started.
    if (_deathTimer > 0) {
      return;
    }
    _collectCoins();
    _checkGoal();
  }

  void _applyHorizontalInput(double dt) {
    var input = (_rightHeld ? 1 : 0) - (_leftHeld ? 1 : 0);
    final reversed = _level.reverseZones.any(
      (zone) => zone.revealed && zone.rect.overlaps(_player.rect),
    );
    if (reversed) {
      input = -input;
    }
    // Ice: while the player's feet overlap an ice sheet, acceleration and
    // braking drop to a fraction — they slide.
    final onIce = _level.iceZones.any(
      (zone) => zone.rect.overlaps(_player.rect),
    );
    final acceleration = _acceleration * (onIce ? 0.15 : 1.0);
    final targetVelocity = input * _moveSpeed;
    final nextVelocity = _moveToward(
      _player.velocity.dx,
      targetVelocity.toDouble(),
      acceleration * dt,
    );
    _player.velocity = Offset(nextVelocity, _player.velocity.dy);
  }

  double _moveToward(double current, double target, double amount) {
    if ((target - current).abs() <= amount) {
      return target;
    }
    return current + (target > current ? amount : -amount);
  }

  void _tryStartJump() {
    if (_jumpBuffer <= 0) {
      return;
    }
    // Coyote time: a jump shortly after leaving a ledge still counts.
    if (!_player.onGround && _coyoteTimer <= 0) {
      return;
    }

    _player.velocity = Offset(_player.velocity.dx, _jumpVelocity);
    _player.onGround = false;
    _player.groundPlatformId = null;
    _jumpBuffer = 0;
    _coyoteTimer = 0;
    _jumpCuttable = true;
    Sfx.jump();
    // On Schrödinger levels every jump flips the worlds — give the flip its
    // own audible tick on top of the jump sweep.
    if (_level.traps.any((trap) => trap is QuantumSwapTrap)) {
      Sfx.swap();
    }

    // A tap that was already released (e.g. a buffered jump) becomes a short
    // hop right away instead of a full-height jump.
    if (!_jumpHeld) {
      _player.velocity = Offset(_player.velocity.dx, _jumpCutVelocity);
      _jumpCuttable = false;
    }

    for (final trap in _level.traps) {
      trap.onPlayerJump(_level, _player);
    }
  }

  void _onJumpPressed() {
    _jumpHeld = true;
    _jumpBuffer = 0.13;
  }

  void _onJumpReleased() {
    _jumpHeld = false;
    // Variable jump height: releasing early trims the remaining rise.
    if (_jumpCuttable && _player.velocity.dy < _jumpCutVelocity) {
      _player.velocity = Offset(_player.velocity.dx, _jumpCutVelocity);
    }
    _jumpCuttable = false;
  }

  void _moveHorizontally(double dt) {
    _player.position += Offset(_player.velocity.dx * dt, 0);

    if (_player.rect.left < 0) {
      _player.position = Offset(0, _player.position.dy);
      _player.velocity = Offset(0, _player.velocity.dy);
    } else if (_player.rect.right > _level.width) {
      _player.position = Offset(
        _level.width - playerSize.width,
        _player.position.dy,
      );
      _player.velocity = Offset(0, _player.velocity.dy);
    }

    for (final platform in _level.solidPlatforms) {
      if (!_player.rect.overlaps(platform.rect)) {
        continue;
      }
      // Resolve along the axis of least penetration rather than the player's
      // velocity sign. This also ejects a stationary player when a moving
      // platform slides into them, instead of leaving them embedded.
      final pushLeft = _player.rect.right - platform.rect.left;
      final pushRight = platform.rect.right - _player.rect.left;
      if (pushLeft < pushRight) {
        _player.position = Offset(
          platform.rect.left - playerSize.width,
          _player.position.dy,
        );
      } else {
        _player.position = Offset(platform.rect.right, _player.position.dy);
      }
      _player.velocity = Offset(0, _player.velocity.dy);
    }
  }

  void _moveVertically(double dt) {
    final previousRect = _player.rect;
    _player.position += Offset(0, _player.velocity.dy * dt);
    _player.onGround = false;
    _player.groundPlatformId = null;

    if (_triggerJumpPad(previousRect)) {
      return;
    }

    for (final platform in _level.solidPlatforms) {
      if (!_player.rect.overlaps(platform.rect)) {
        continue;
      }

      if (_player.velocity.dy >= 0 &&
          previousRect.bottom <= platform.rect.top + 4) {
        _player.position = Offset(
          _player.position.dx,
          platform.rect.top - playerSize.height,
        );
        _player.velocity = Offset(_player.velocity.dx, 0);
        _player.onGround = true;
        _player.groundPlatformId = platform.id;
        for (final trap in _level.traps) {
          trap.onPlayerLanding(_level, _player, platform);
        }
      } else if (_player.velocity.dy < 0 &&
          previousRect.top >= platform.rect.bottom - 4) {
        _player.position = Offset(_player.position.dx, platform.rect.bottom);
        _player.velocity = Offset(_player.velocity.dx, 0);
      }
    }
  }

  bool _triggerJumpPad(Rect previousRect) {
    if (_player.velocity.dy < 0) {
      return false;
    }

    for (final pad in _level.jumpPads) {
      if (pad.cooldown > 0) {
        continue;
      }
      final landedOnPad =
          _player.rect.overlaps(pad.rect.inflate(2)) &&
          previousRect.bottom <= pad.rect.top + 6;
      if (!landedOnPad) {
        continue;
      }

      _player.position = Offset(
        _player.position.dx,
        pad.rect.top - playerSize.height,
      );
      _player.velocity = Offset(
        _player.velocity.dx,
        pad.launchVelocityFor(_player),
      );
      _player.onGround = false;
      _player.groundPlatformId = null;
      // Pad launches are not jumps: releasing the jump button must not trim
      // them, or the pad would lose its whole point.
      _jumpCuttable = false;
      pad.cooldown = 0.28;
      pad.flash = 0.45;
      Sfx.boing();
      return true;
    }
    return false;
  }

  void _updateCheckpointsAndZones() {
    final checkpointsLocked =
        _checkpointRecaptureLockedForReturnTrip || _secondLapActive;
    for (final checkpoint in _level.checkpoints) {
      // Fake checkpoints never grant a spawn — their trap handles them.
      if (checkpoint.fake || !checkpoint.visible) {
        continue;
      }
      // Checkpoints normally re-arm in both directions: touching any flag
      // (even one already reached) makes it the current spawn. Level 21 is
      // the exception after the fake goal reveals the real goal back at the
      // start: keep the farthest checkpoint so one death does not force the
      // whole outward trip again.
      if (!checkpointsLocked &&
          _checkpointId != checkpoint.id &&
          _player.rect.overlaps(checkpoint.rect.inflate(4))) {
        checkpoint.reached = true;
        checkpoint.flash = 0.6;
        _checkpointSpawn = checkpoint.spawnPosition;
        _checkpointId = checkpoint.id;
        // A fresh section deserves a fresh past: capturing a checkpoint
        // wipes the echo's movement history.
        for (final trap in _level.traps.whereType<EchoTrap>()) {
          trap.clearTrail();
        }
        Sfx.checkpoint();
      }
    }
    for (final zone in _level.reverseZones) {
      if (!zone.revealed && zone.rect.overlaps(_player.rect)) {
        zone.revealed = true;
        zone.flash = 0.8;
        Sfx.trap();
      }
    }
  }

  bool get _checkpointRecaptureLockedForReturnTrip =>
      _level.number == 21 && _level.goal.visible;

  void _collectCoins() {
    for (final coin in _level.coins) {
      if (coin.collected || !_player.rect.overlaps(coin.rect.inflate(4))) {
        continue;
      }
      coin.collected = true;
      if (coin.id == 'rare-coin') {
        _rareCoinRect = null; // Banked: don't respawn it after a death.
        unawaited(GameEconomy.collectRareCoin(_level.number, coin.value));
      } else {
        unawaited(GameEconomy.addCoins(coin.value));
      }
      Sfx.checkpoint();
    }
  }

  /// Plays the trap sound whenever any trap fired this frame, regardless of
  /// which callback (proximity, jump, landing, position) triggered it.
  void _notifyTrapSounds() {
    final triggered = _level.traps.where((trap) => trap.triggered).length;
    if (triggered > _triggeredTrapCount) {
      Sfx.trap();
    }
    _triggeredTrapCount = triggered;
  }

  void _checkHazardsAndBounds() {
    if (_player.rect.top > worldHeight + 160) {
      _die();
      return;
    }

    for (final spike in _level.spikes) {
      if (!spike.visible || !spike.dangerous) {
        continue;
      }
      // Test the actual drawn triangle (slightly shrunk for fairness) so the
      // player no longer dies in the empty corners beside the spike's tip.
      if (spikeHitsPlayer(spike, _player.rect.deflate(3))) {
        _die();
        return;
      }
    }

    for (final hazard in _level.hazards) {
      if (!hazard.visible || !hazard.dangerous) {
        continue;
      }
      if (_player.rect.overlaps(hazard.rect.deflate(3))) {
        _die();
        return;
      }
    }

    // Traps that project a lethal body into the world (the evil twin, the
    // echo, ...) kill on touch; jump over them.
    for (final trap in _level.traps) {
      final body = trap.hazardRect(_player);
      if (body != null && _player.rect.deflate(3).overlaps(body.deflate(3))) {
        _die();
        return;
      }
    }
  }

  void _die() {
    if (_deathTimer > 0) {
      return;
    }
    _deathTimer = _deathDuration;
    _deathElapsed = 0;
    _deathsThisLevel++;
    GameStats.totalDeaths++;
    final origin = _player.center;
    for (var i = 0; i < 16; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 90 + _random.nextDouble() * 190;
      _particles.add(
        DeathParticle(
          position: origin,
          velocity: Offset(
            math.cos(angle) * speed,
            math.sin(angle) * speed - 130,
          ),
        ),
      );
    }
    Sfx.death();
  }

  void _checkGoal() {
    if (!_level.goal.visible) {
      return;
    }
    if (!_player.rect.overlaps(_level.goal.rect.deflate(4))) {
      return;
    }

    Sfx.goal();

    if (_levelIndex == _levels.length - 1) {
      _finishRun('/win');
      return;
    }

    LevelProgress.unlockThrough(_levelIndex + 2);
    if (_levelIndex == _fakeWinLevelIndex && _levels.length > 15) {
      _finishRun('/fakewin');
      return;
    }

    _loadLevel(_levelIndex + 1);
  }

  void _finishRun(String route) {
    _transitioning = true;
    _ticker.stop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  void _restartLevel() {
    // A manual restart is a fresh attempt: it also clears the checkpoint.
    _checkpointSpawn = null;
    _checkpointId = null;
    _loadLevel(_levelIndex);
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyRepeatEvent) {
      return;
    }
    final key = event.logicalKey;
    final isDown = event is KeyDownEvent;

    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      setState(() => _leftHeld = isDown);
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      setState(() => _rightHeld = isDown);
    } else if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.keyW) {
      setState(isDown ? _onJumpPressed : _onJumpReleased);
    } else if (key == LogicalKeyboardKey.keyR && isDown) {
      setState(_restartLevel);
    }
  }

  double _cameraFor(Size size) {
    if (size.height <= 0 || size.width <= 0) {
      return 0;
    }
    final visibleWorldWidth = worldHeight * size.width / size.height;
    final maxCamera = math.max(0.0, _level.width - visibleWorldWidth);
    final desired = _player.center.dx - visibleWorldWidth * 0.42;
    var camera = desired.clamp(0.0, maxCamera).toDouble();
    if (_deathTimer > 0) {
      final strength = 7 * (_deathTimer / _deathDuration);
      camera += math.sin(_deathElapsed * 55) * strength;
    }
    return camera;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _GameTopBar(
                levelText: 'Level ${_levelIndex + 1} / ${_levels.length}',
                title: _level.title,
                deaths: _deathsThisLevel,
                onRestart: () {
                  setState(_restartLevel);
                  _focusNode.requestFocus();
                },
                onMenu: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (_) => false);
                },
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    return Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (_) => _focusNode.requestFocus(),
                      child: ClipRect(
                        child: CustomPaint(
                          painter: GamePainter(
                            level: _level,
                            player: _player,
                            playerColor: GameEconomy.selectedSkin.color,
                            cameraX: _cameraFor(size),
                            particles: _particles,
                            deathProgress: _deathTimer > 0
                                ? _deathTimer / _deathDuration
                                : 0,
                            hidePlayer: _deathTimer > 0,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _ControlPanel(
                leftHeld: _leftHeld,
                rightHeld: _rightHeld,
                onLeftDown: () => setState(() => _leftHeld = true),
                onLeftUp: () => setState(() => _leftHeld = false),
                onRightDown: () => setState(() => _rightHeld = true),
                onRightUp: () => setState(() => _rightHeld = false),
                onJumpDown: () => setState(_onJumpPressed),
                onJumpUp: () => setState(_onJumpReleased),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameTopBar extends StatelessWidget {
  const _GameTopBar({
    required this.levelText,
    required this.title,
    required this.deaths,
    required this.onRestart,
    required this.onMenu,
  });

  final String levelText;
  final String title;
  final int deaths;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Menu',
            onPressed: onMenu,
            icon: const Icon(Icons.home_rounded),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  levelText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.heart_broken_rounded,
                  size: 18,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(width: 3),
                Text(
                  '$deaths',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: Sfx.muted,
            builder: (context, muted, _) {
              return IconButton(
                tooltip: muted ? 'Unmute' : 'Mute',
                onPressed: () => Sfx.muted.value = !muted,
                icon: Icon(
                  muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Restart',
            onPressed: onRestart,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.leftHeld,
    required this.rightHeld,
    required this.onLeftDown,
    required this.onLeftUp,
    required this.onRightDown,
    required this.onRightUp,
    required this.onJumpDown,
    required this.onJumpUp,
  });

  final bool leftHeld;
  final bool rightHeld;
  final VoidCallback onLeftDown;
  final VoidCallback onLeftUp;
  final VoidCallback onRightDown;
  final VoidCallback onRightUp;
  final VoidCallback onJumpDown;
  final VoidCallback onJumpUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      color: const Color(0xFFE2E8F0),
      child: Row(
        children: [
          _HoldButton(
            label: 'Move left',
            icon: Icons.arrow_back_rounded,
            active: leftHeld,
            onDown: onLeftDown,
            onUp: onLeftUp,
          ),
          const SizedBox(width: 14),
          _HoldButton(
            label: 'Move right',
            icon: Icons.arrow_forward_rounded,
            active: rightHeld,
            onDown: onRightDown,
            onUp: onRightUp,
          ),
          const Spacer(),
          _HoldButton(
            label: 'Jump',
            icon: Icons.keyboard_arrow_up_rounded,
            active: false,
            large: true,
            onDown: onJumpDown,
            onUp: onJumpUp,
          ),
        ],
      ),
    );
  }
}

class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onDown,
    required this.onUp,
    this.large = false,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool large;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    final size = large ? 78.0 : 68.0;
    final background = active ? const Color(0xFF1D4ED8) : Colors.white;
    final foreground = active ? Colors.white : const Color(0xFF0F172A);

    return Semantics(
      button: true,
      label: label,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        // Raw pointer events (not tap gestures) so a held button keeps firing
        // when the finger drifts past the touch slop — a tap recognizer would
        // cancel and silently stop movement mid-jump.
        onPointerDown: (_) => onDown(),
        onPointerUp: (_) => onUp(),
        onPointerCancel: (_) => onUp(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: large ? 40 : 34, color: foreground),
        ),
      ),
    );
  }
}
