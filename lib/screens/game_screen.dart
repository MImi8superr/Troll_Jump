import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../game/collision.dart';
import '../game/game_painter.dart';
import '../game/level_progress.dart';
import '../game/levels.dart';
import '../game/models.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.initialLevelIndex = 0});

  final int initialLevelIndex;

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

  late final List<Level> _levels;
  late final Ticker _ticker;
  late Level _level;
  late Player _player;

  int _levelIndex = 0;
  bool _leftHeld = false;
  bool _rightHeld = false;
  bool _transitioning = false;
  double _jumpBuffer = 0;
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _levels = buildLevels();
    _loadLevel(widget.initialLevelIndex.clamp(0, _levels.length - 1));
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _loadLevel(int index) {
    _levelIndex = index;
    _level = _levels[index].copy();
    _player = Player(start: _level.playerStart);
    _leftHeld = false;
    _rightHeld = false;
    _jumpBuffer = 0;
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
    _jumpBuffer = math.max(0, _jumpBuffer - dt);

    _applyHorizontalInput(dt);
    _tryStartJump();

    for (final trap in _level.traps) {
      trap.update(_level, _player, dt);
    }
    _level.updateObjects(dt, _player);

    _player.velocity = Offset(
      _player.velocity.dx,
      math.min(_maxFallSpeed, _player.velocity.dy + _gravity * dt),
    );

    _moveHorizontally(dt);
    _moveVertically(dt);
    _checkHazardsAndBounds();
    _checkGoal();
  }

  void _applyHorizontalInput(double dt) {
    final input = (_rightHeld ? 1 : 0) - (_leftHeld ? 1 : 0);
    final targetVelocity = input * _moveSpeed;
    final nextVelocity = _moveToward(
      _player.velocity.dx,
      targetVelocity.toDouble(),
      _acceleration * dt,
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
    if (_jumpBuffer <= 0 || !_player.onGround) {
      return;
    }

    _player.velocity = Offset(_player.velocity.dx, _jumpVelocity);
    _player.onGround = false;
    _player.groundPlatformId = null;
    _jumpBuffer = 0;

    for (final trap in _level.traps) {
      trap.onPlayerJump(_level, _player);
    }
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
      pad.cooldown = 0.28;
      pad.flash = 0.45;
      return true;
    }
    return false;
  }

  void _checkHazardsAndBounds() {
    if (_player.rect.top > worldHeight + 160) {
      _restartLevel();
      return;
    }

    for (final spike in _level.spikes) {
      if (!spike.visible || !spike.dangerous) {
        continue;
      }
      // Test the actual drawn triangle (slightly shrunk for fairness) so the
      // player no longer dies in the empty corners beside the spike's tip.
      if (spikeHitsPlayer(spike, _player.rect.deflate(3))) {
        _restartLevel();
        return;
      }
    }

    for (final hazard in _level.hazards) {
      if (!hazard.visible || !hazard.dangerous) {
        continue;
      }
      if (_player.rect.overlaps(hazard.rect.deflate(3))) {
        _restartLevel();
        return;
      }
    }
  }

  void _checkGoal() {
    if (!_player.rect.overlaps(_level.goal.rect.deflate(4))) {
      return;
    }

    if (_levelIndex == _levels.length - 1) {
      _transitioning = true;
      _ticker.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed('/win');
      });
      return;
    }

    LevelProgress.unlockThrough(_levelIndex + 2);
    _loadLevel(_levelIndex + 1);
  }

  void _restartLevel() {
    _loadLevel(_levelIndex);
  }

  void _queueJump() {
    setState(() {
      _jumpBuffer = 0.13;
    });
  }

  double _cameraFor(Size size) {
    if (size.height <= 0 || size.width <= 0) {
      return 0;
    }
    final visibleWorldWidth = worldHeight * size.width / size.height;
    final maxCamera = math.max(0.0, _level.width - visibleWorldWidth);
    final desired = _player.center.dx - visibleWorldWidth * 0.42;
    return desired.clamp(0.0, maxCamera).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _GameTopBar(
              levelText: 'Level ${_levelIndex + 1} / ${_levels.length}',
              title: _level.title,
              onRestart: () => setState(_restartLevel),
              onMenu: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/levels', (_) => false);
              },
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  return ClipRect(
                    child: CustomPaint(
                      painter: GamePainter(
                        level: _level,
                        player: _player,
                        cameraX: _cameraFor(size),
                      ),
                      child: const SizedBox.expand(),
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
              onJumpDown: _queueJump,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTopBar extends StatelessWidget {
  const _GameTopBar({
    required this.levelText,
    required this.title,
    required this.onRestart,
    required this.onMenu,
  });

  final String levelText;
  final String title;
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
  });

  final bool leftHeld;
  final bool rightHeld;
  final VoidCallback onLeftDown;
  final VoidCallback onLeftUp;
  final VoidCallback onRightDown;
  final VoidCallback onRightUp;
  final VoidCallback onJumpDown;

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
            onUp: () {},
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
