import 'dart:math' as math;

import 'package:flutter/material.dart';

const double worldHeight = 600;
const double floorY = 520;
const Size playerSize = Size(34, 46);

enum SpikeDirection { up, down }

enum TrapTriggerType {
  playerProximity,
  playerJump,
  playerLanding,
  playerXPosition,
}

class Player {
  Player({required Offset start}) : position = start, startPosition = start;

  final Offset startPosition;
  Offset position;
  Offset velocity = Offset.zero;
  bool onGround = false;
  String? groundPlatformId;

  Rect get rect => position & playerSize;
  Offset get center => rect.center;

  void reset() {
    position = startPosition;
    velocity = Offset.zero;
    onGround = false;
    groundPlatformId = null;
  }
}

class Level {
  Level({
    required this.number,
    required this.title,
    required this.width,
    required this.playerStart,
    required this.platforms,
    required this.spikes,
    required this.goal,
    this.hazards = const [],
    this.jumpPads = const [],
    this.traps = const [],
  });

  final int number;
  final String title;
  final double width;
  final Offset playerStart;
  final List<Platform> platforms;
  final List<Spike> spikes;
  final List<HazardBlock> hazards;
  final List<JumpPad> jumpPads;
  final Goal goal;
  final List<Trap> traps;

  Level copy() {
    return Level(
      number: number,
      title: title,
      width: width,
      playerStart: playerStart,
      platforms: platforms.map((platform) => platform.copy()).toList(),
      spikes: spikes.map((spike) => spike.copy()).toList(),
      hazards: hazards.map((hazard) => hazard.copy()).toList(),
      jumpPads: jumpPads.map((pad) => pad.copy()).toList(),
      goal: goal.copy(),
      traps: traps.map((trap) => trap.copy()).toList(),
    );
  }

  Iterable<Platform> get solidPlatforms {
    return platforms.where((platform) => platform.visible && platform.solid);
  }

  Platform? platformById(String id) {
    for (final platform in platforms) {
      if (platform.id == id) {
        return platform;
      }
    }
    return null;
  }

  Spike? spikeById(String id) {
    for (final spike in spikes) {
      if (spike.id == id) {
        return spike;
      }
    }
    return null;
  }

  void updateObjects(double dt, Player player) {
    for (final platform in platforms) {
      final movement = platform.update(dt);
      if (player.onGround && player.groundPlatformId == platform.id) {
        player.position += movement;
      }
    }
    for (final spike in spikes) {
      spike.update(dt);
    }
    for (final hazard in hazards) {
      hazard.update(dt);
    }
    for (final pad in jumpPads) {
      pad.update(dt);
    }
    goal.update(dt);
  }
}

class Platform {
  Platform({
    required this.id,
    required this.rect,
    this.color = const Color(0xFF263238),
    this.solid = true,
    this.visible = true,
    this.active = false,
    this.patrol = false,
    this.velocity = Offset.zero,
    this.minX,
    this.maxX,
    this.flash = 0,
    this.cracked = false,
  });

  final String id;
  Rect rect;
  Color color;
  bool solid;
  bool visible;
  bool active;
  bool patrol;
  Offset velocity;
  double? minX;
  double? maxX;
  double flash;
  bool cracked;

  Platform copy() {
    return Platform(
      id: id,
      rect: rect,
      color: color,
      solid: solid,
      visible: visible,
      active: active,
      patrol: patrol,
      velocity: velocity,
      minX: minX,
      maxX: maxX,
      flash: flash,
      cracked: cracked,
    );
  }

  Offset update(double dt) {
    flash = math.max(0, flash - dt);
    if (!active || velocity == Offset.zero) {
      return Offset.zero;
    }

    var dx = velocity.dx * dt;
    final dy = velocity.dy * dt;

    if (dx > 0 && maxX != null && rect.left + dx >= maxX!) {
      dx = maxX! - rect.left;
      if (patrol) {
        velocity = Offset(-velocity.dx, velocity.dy);
      } else {
        active = false;
        velocity = Offset.zero;
      }
    } else if (dx < 0 && minX != null && rect.left + dx <= minX!) {
      dx = minX! - rect.left;
      if (patrol) {
        velocity = Offset(-velocity.dx, velocity.dy);
      } else {
        active = false;
        velocity = Offset.zero;
      }
    }

    final movement = Offset(dx, dy);
    rect = rect.shift(movement);
    return movement;
  }
}

class Spike {
  Spike({
    required this.id,
    required this.rect,
    this.direction = SpikeDirection.up,
    this.visible = true,
    this.dangerous = true,
    this.velocity = Offset.zero,
    this.targetLeft,
    this.targetTop,
    this.targetBottom,
    this.flash = 0,
  });

  final String id;
  Rect rect;
  SpikeDirection direction;
  bool visible;
  bool dangerous;
  Offset velocity;
  double? targetLeft;
  double? targetTop;
  double? targetBottom;
  double flash;

  Spike copy() {
    return Spike(
      id: id,
      rect: rect,
      direction: direction,
      visible: visible,
      dangerous: dangerous,
      velocity: velocity,
      targetLeft: targetLeft,
      targetTop: targetTop,
      targetBottom: targetBottom,
      flash: flash,
    );
  }

  void update(double dt) {
    flash = math.max(0, flash - dt);
    if (velocity == Offset.zero) {
      return;
    }

    var dx = velocity.dx * dt;
    var dy = velocity.dy * dt;

    if (dx > 0 && targetLeft != null && rect.left + dx >= targetLeft!) {
      dx = targetLeft! - rect.left;
      velocity = Offset.zero;
      targetLeft = null;
    } else if (dx < 0 && targetLeft != null && rect.left + dx <= targetLeft!) {
      dx = targetLeft! - rect.left;
      velocity = Offset.zero;
      targetLeft = null;
    }

    if (dy > 0 && targetBottom != null && rect.bottom + dy >= targetBottom!) {
      dy = targetBottom! - rect.bottom;
      velocity = Offset.zero;
      targetBottom = null;
    } else if (dy < 0 && targetTop != null && rect.top + dy <= targetTop!) {
      dy = targetTop! - rect.top;
      velocity = Offset.zero;
      targetTop = null;
    }

    rect = rect.shift(Offset(dx, dy));
  }
}

class Goal {
  Goal({
    required this.rect,
    this.velocity = Offset.zero,
    this.targetLeft,
    this.flash = 0,
  });

  Rect rect;
  Offset velocity;
  double? targetLeft;
  double flash;

  Goal copy() {
    return Goal(
      rect: rect,
      velocity: velocity,
      targetLeft: targetLeft,
      flash: flash,
    );
  }

  void update(double dt) {
    flash = math.max(0, flash - dt);
    if (velocity == Offset.zero) {
      return;
    }

    var dx = velocity.dx * dt;
    if (dx > 0 && targetLeft != null && rect.left + dx >= targetLeft!) {
      dx = targetLeft! - rect.left;
      velocity = Offset.zero;
      targetLeft = null;
    } else if (dx < 0 && targetLeft != null && rect.left + dx <= targetLeft!) {
      dx = targetLeft! - rect.left;
      velocity = Offset.zero;
      targetLeft = null;
    }
    rect = rect.shift(Offset(dx, velocity.dy * dt));
  }
}

class HazardBlock {
  HazardBlock({
    required this.id,
    required this.rect,
    this.visible = true,
    this.dangerous = true,
    this.flash = 0,
  });

  final String id;
  Rect rect;
  bool visible;
  bool dangerous;
  double flash;

  HazardBlock copy() {
    return HazardBlock(
      id: id,
      rect: rect,
      visible: visible,
      dangerous: dangerous,
      flash: flash,
    );
  }

  void update(double dt) {
    flash = math.max(0, flash - dt);
  }
}

class JumpPad {
  JumpPad({
    required this.id,
    required this.rect,
    this.gentleVelocity = -520,
    this.wildVelocity = -820,
    this.speedThreshold = 145,
    this.cooldown = 0,
    this.flash = 0,
  });

  final String id;
  Rect rect;
  double gentleVelocity;
  double wildVelocity;
  double speedThreshold;
  double cooldown;
  double flash;

  JumpPad copy() {
    return JumpPad(
      id: id,
      rect: rect,
      gentleVelocity: gentleVelocity,
      wildVelocity: wildVelocity,
      speedThreshold: speedThreshold,
      cooldown: cooldown,
      flash: flash,
    );
  }

  void update(double dt) {
    cooldown = math.max(0, cooldown - dt);
    flash = math.max(0, flash - dt);
  }

  double launchVelocityFor(Player player) {
    if (player.velocity.dx.abs() > speedThreshold) {
      return wildVelocity;
    }
    return gentleVelocity;
  }
}

/// Troll traps are small state machines attached to level objects.
///
/// Each trap declares the kind of signal that wakes it up: player proximity,
/// a jump press, a platform landing, or the player reaching an x-position.
/// The trap then mutates ordinary reusable objects such as spikes, platforms,
/// and the goal. This keeps level data readable and lets the same trap classes
/// be mixed together without hard-coding level-specific behavior in the game
/// loop.
abstract class Trap {
  Trap(this.triggerType);

  final TrapTriggerType triggerType;
  bool triggered = false;

  void update(Level level, Player player, double dt) {}

  void onPlayerJump(Level level, Player player) {}

  void onPlayerLanding(Level level, Player player, Platform platform) {}

  Trap copy();
}

class SlideSpikeTrap extends Trap {
  SlideSpikeTrap({
    required this.spikeId,
    this.triggerDistance = 110,
    this.triggerX,
    this.moveDistance = 120,
    this.speed = 360,
  }) : super(TrapTriggerType.playerProximity);

  final String spikeId;
  final double triggerDistance;
  final double? triggerX;
  final double moveDistance;
  final double speed;

  @override
  void update(Level level, Player player, double dt) {
    final spike = level.spikeById(spikeId);
    if (spike == null || triggered) {
      return;
    }

    final closeToSpike =
        player.rect.right > spike.rect.left - triggerDistance &&
        player.rect.left < spike.rect.right + triggerDistance;
    final crossedLine = triggerX != null && player.center.dx >= triggerX!;
    if (closeToSpike || crossedLine) {
      triggered = true;
      spike.velocity = Offset(speed, 0);
      spike.targetLeft = spike.rect.left + moveDistance;
      spike.flash = 0.45;
    }
  }

  @override
  Trap copy() {
    return SlideSpikeTrap(
      spikeId: spikeId,
      triggerDistance: triggerDistance,
      triggerX: triggerX,
      moveDistance: moveDistance,
      speed: speed,
    );
  }
}

class DisappearPlatformTrap extends Trap {
  DisappearPlatformTrap({required this.platformId, this.delay = 0.38})
    : super(TrapTriggerType.playerLanding);

  final String platformId;
  final double delay;
  double _timer = 0;

  @override
  void onPlayerLanding(Level level, Player player, Platform platform) {
    if (triggered || platform.id != platformId) {
      return;
    }
    triggered = true;
    _timer = delay;
    platform.flash = delay + 0.2;
  }

  @override
  void update(Level level, Player player, double dt) {
    if (!triggered) {
      return;
    }
    _timer -= dt;
    if (_timer <= 0) {
      final platform = level.platformById(platformId);
      if (platform != null) {
        platform.visible = false;
        platform.solid = false;
      }
    }
  }

  @override
  Trap copy() {
    return DisappearPlatformTrap(platformId: platformId, delay: delay);
  }
}

class DropSpikeTrap extends Trap {
  DropSpikeTrap({
    required this.spikeId,
    required this.triggerX,
    this.speed = 560,
    this.targetBottom = floorY,
  }) : super(TrapTriggerType.playerXPosition);

  final String spikeId;
  final double triggerX;
  final double speed;
  final double targetBottom;

  @override
  void update(Level level, Player player, double dt) {
    final spike = level.spikeById(spikeId);
    if (spike == null || triggered) {
      return;
    }
    if (player.center.dx >= triggerX) {
      triggered = true;
      spike.velocity = Offset(0, speed);
      spike.targetBottom = targetBottom;
      spike.flash = 0.5;
    }
  }

  @override
  Trap copy() {
    return DropSpikeTrap(
      spikeId: spikeId,
      triggerX: triggerX,
      speed: speed,
      targetBottom: targetBottom,
    );
  }
}

class GoalRetreatTrap extends Trap {
  GoalRetreatTrap({
    this.triggerDistance = 100,
    this.retreatDistance = 120,
    this.speed = 260,
  }) : super(TrapTriggerType.playerProximity);

  final double triggerDistance;
  final double retreatDistance;
  final double speed;

  @override
  void update(Level level, Player player, double dt) {
    if (triggered) {
      return;
    }
    final goal = level.goal;
    final close =
        player.rect.right >= goal.rect.left - triggerDistance &&
        player.rect.left < goal.rect.left;
    if (close) {
      triggered = true;
      goal.velocity = Offset(speed, 0);
      goal.targetLeft = goal.rect.left + retreatDistance;
      goal.flash = 0.55;
    }
  }

  @override
  Trap copy() {
    return GoalRetreatTrap(
      triggerDistance: triggerDistance,
      retreatDistance: retreatDistance,
      speed: speed,
    );
  }
}

class ActivateMovingPlatformTrap extends Trap {
  ActivateMovingPlatformTrap({
    required this.platformId,
    required this.speed,
    required this.minX,
    required this.maxX,
    this.patrol = true,
  }) : super(TrapTriggerType.playerJump);

  final String platformId;
  final double speed;
  final double minX;
  final double maxX;
  final bool patrol;

  @override
  void onPlayerJump(Level level, Player player) {
    if (triggered) {
      return;
    }
    final platform = level.platformById(platformId);
    if (platform == null) {
      return;
    }
    triggered = true;
    platform.active = true;
    platform.velocity = Offset(speed, 0);
    platform.minX = minX;
    platform.maxX = maxX;
    platform.patrol = patrol;
    platform.flash = 0.45;
  }

  @override
  Trap copy() {
    return ActivateMovingPlatformTrap(
      platformId: platformId,
      speed: speed,
      minX: minX,
      maxX: maxX,
      patrol: patrol,
    );
  }
}

class RevealSpikeTrap extends Trap {
  RevealSpikeTrap({
    required this.spikeId,
    this.triggerDistance = 105,
    this.triggerX,
  }) : super(TrapTriggerType.playerProximity);

  final String spikeId;
  final double triggerDistance;
  final double? triggerX;

  @override
  void update(Level level, Player player, double dt) {
    final spike = level.spikeById(spikeId);
    if (spike == null || triggered) {
      return;
    }
    final closeToSpike =
        player.rect.right > spike.rect.left - triggerDistance &&
        player.rect.left < spike.rect.right + triggerDistance;
    final crossedLine = triggerX != null && player.center.dx >= triggerX!;
    if (closeToSpike || crossedLine) {
      triggered = true;
      spike.visible = true;
      spike.dangerous = true;
      spike.flash = 0.6;
    }
  }

  @override
  Trap copy() {
    return RevealSpikeTrap(
      spikeId: spikeId,
      triggerDistance: triggerDistance,
      triggerX: triggerX,
    );
  }
}

class BreakPlatformTrap extends Trap {
  BreakPlatformTrap({
    required this.platformId,
    required this.triggerX,
    this.delay = 0.22,
  }) : super(TrapTriggerType.playerXPosition);

  final String platformId;
  final double triggerX;
  final double delay;
  double _timer = 0;

  @override
  void update(Level level, Player player, double dt) {
    final platform = level.platformById(platformId);
    if (platform == null) {
      return;
    }

    if (!triggered && player.center.dx >= triggerX) {
      triggered = true;
      _timer = delay;
      platform.flash = delay + 0.2;
    }

    if (!triggered) {
      return;
    }
    _timer -= dt;
    if (_timer <= 0) {
      platform.visible = false;
      platform.solid = false;
    }
  }

  @override
  Trap copy() {
    return BreakPlatformTrap(
      platformId: platformId,
      triggerX: triggerX,
      delay: delay,
    );
  }
}

class FleePlatformOnJumpTrap extends Trap {
  FleePlatformOnJumpTrap({
    required this.platformId,
    this.triggerDistance = 260,
    this.moveDistance = 130,
    this.speed = 300,
  }) : super(TrapTriggerType.playerJump);

  final String platformId;
  final double triggerDistance;
  final double moveDistance;
  final double speed;

  @override
  void onPlayerJump(Level level, Player player) {
    if (triggered) {
      return;
    }
    final platform = level.platformById(platformId);
    if (platform == null) {
      return;
    }
    final close =
        (player.center.dx - platform.rect.center.dx).abs() < triggerDistance;
    if (!close) {
      return;
    }
    triggered = true;
    platform.active = true;
    platform.velocity = Offset(speed, 0);
    platform.minX = platform.rect.left;
    platform.maxX = platform.rect.left + moveDistance;
    platform.patrol = false;
    platform.flash = 0.5;
  }

  @override
  Trap copy() {
    return FleePlatformOnJumpTrap(
      platformId: platformId,
      triggerDistance: triggerDistance,
      moveDistance: moveDistance,
      speed: speed,
    );
  }
}

class ReverseFirstTrap extends Trap {
  ReverseFirstTrap({
    required this.spikeId,
    required this.disarmX,
    required this.triggerX,
  }) : super(TrapTriggerType.playerXPosition);

  final String spikeId;
  final double disarmX;
  final double triggerX;
  bool disarmed = false;

  @override
  void update(Level level, Player player, double dt) {
    final spike = level.spikeById(spikeId);
    if (spike == null) {
      return;
    }

    if (!disarmed && player.rect.left <= disarmX) {
      disarmed = true;
      spike.visible = false;
      spike.dangerous = false;
    }

    if (!triggered && !disarmed && player.center.dx >= triggerX) {
      triggered = true;
      spike.visible = true;
      spike.dangerous = true;
      spike.flash = 0.7;
    }
  }

  @override
  Trap copy() {
    return ReverseFirstTrap(
      spikeId: spikeId,
      disarmX: disarmX,
      triggerX: triggerX,
    );
  }
}
