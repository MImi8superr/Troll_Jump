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
    this.coins = const [],
    this.traps = const [],
    this.checkpoints = const [],
    this.reverseZones = const [],
    this.iceZones = const [],
    this.darkZones = const [],
    this.decoyGoal,
  });

  final int number;
  final String title;
  final double width;
  final Offset playerStart;
  final List<Platform> platforms;
  final List<Spike> spikes;
  final List<HazardBlock> hazards;
  final List<JumpPad> jumpPads;
  final List<Coin> coins;
  final Goal goal;
  final List<Trap> traps;
  final List<Checkpoint> checkpoints;
  final List<ReverseZone> reverseZones;
  final List<IceZone> iceZones;
  final List<DarkZone> darkZones;
  final Goal? decoyGoal;

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
      coins: coins.map((coin) => coin.copy()).toList(),
      goal: goal.copy(),
      traps: traps.map((trap) => trap.copy()).toList(),
      checkpoints: checkpoints.map((cp) => cp.copy()).toList(),
      reverseZones: reverseZones.map((zone) => zone.copy()).toList(),
      iceZones: iceZones.map((zone) => zone.copy()).toList(),
      darkZones: darkZones.map((zone) => zone.copy()).toList(),
      decoyGoal: decoyGoal?.copy(),
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

  Checkpoint? checkpointById(String id) {
    for (final checkpoint in checkpoints) {
      if (checkpoint.id == id) {
        return checkpoint;
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
    for (final coin in coins) {
      coin.update(dt);
    }
    for (final checkpoint in checkpoints) {
      checkpoint.update(dt);
    }
    for (final zone in reverseZones) {
      zone.update(dt);
    }
    for (final zone in darkZones) {
      zone.update(dt, player);
    }
    goal.update(dt);
    decoyGoal?.update(dt);
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
    this.ghost = false,
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

  /// Rendered as a faint outline of itself: present, but not real right
  /// now. Quantum platforms use this for the currently-inactive world;
  /// ghost platforms should also be non-solid.
  bool ghost;

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
      ghost: ghost,
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
    // Stop each axis independently so a spike given both an x and y target (a
    // diagonal move) isn't frozen the instant either axis arrives.
    var vx = velocity.dx;
    var vy = velocity.dy;

    if (dx > 0 && targetLeft != null && rect.left + dx >= targetLeft!) {
      dx = targetLeft! - rect.left;
      vx = 0;
      targetLeft = null;
    } else if (dx < 0 && targetLeft != null && rect.left + dx <= targetLeft!) {
      dx = targetLeft! - rect.left;
      vx = 0;
      targetLeft = null;
    }

    if (dy > 0 && targetBottom != null && rect.bottom + dy >= targetBottom!) {
      dy = targetBottom! - rect.bottom;
      vy = 0;
      targetBottom = null;
    } else if (dy < 0 && targetTop != null && rect.top + dy <= targetTop!) {
      dy = targetTop! - rect.top;
      vy = 0;
      targetTop = null;
    }

    velocity = Offset(vx, vy);
    rect = rect.shift(Offset(dx, dy));
  }
}

class Goal {
  Goal({
    required this.rect,
    this.velocity = Offset.zero,
    this.targetLeft,
    this.flash = 0,
    this.visible = true,
  });

  Rect rect;
  Offset velocity;
  double? targetLeft;
  double flash;
  bool visible;

  Goal copy() {
    return Goal(
      rect: rect,
      velocity: velocity,
      targetLeft: targetLeft,
      flash: flash,
      visible: visible,
    );
  }

  void update(double dt) {
    flash = math.max(0, flash - dt);
    if (velocity == Offset.zero) {
      return;
    }

    // Capture the vertical step before the arrival check can zero velocity,
    // so a moving goal's dy isn't silently dropped on the frame it stops.
    var dx = velocity.dx * dt;
    final dy = velocity.dy * dt;
    if (dx > 0 && targetLeft != null && rect.left + dx >= targetLeft!) {
      dx = targetLeft! - rect.left;
      velocity = Offset.zero;
      targetLeft = null;
    } else if (dx < 0 && targetLeft != null && rect.left + dx <= targetLeft!) {
      dx = targetLeft! - rect.left;
      velocity = Offset.zero;
      targetLeft = null;
    }
    rect = rect.shift(Offset(dx, dy));
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

/// A mid-level respawn flag. Once touched, deaths restart the level from
/// here instead of the level start (the level itself still resets fully, so
/// traps re-arm — the checkpoint only moves the spawn point).
///
/// A [fake] checkpoint looks identical to an unreached real one but never
/// grants a spawn point; a [FakeCheckpointTrap] springs it instead.
class Checkpoint {
  Checkpoint({
    required this.id,
    required this.rect,
    this.reached = false,
    this.flash = 0,
    this.fake = false,
    this.visible = true,
    this.spawnOverride,
  });

  final String id;
  Rect rect;
  bool reached;
  double flash;
  final bool fake;
  bool visible;

  /// Where deaths respawn after touching this checkpoint. Defaults to the
  /// ground under the flag; a floating flag (grabbed mid-jump) must override
  /// this with a safe spot on solid ground.
  final Offset? spawnOverride;

  Offset get spawnPosition =>
      spawnOverride ??
      Offset(
        rect.center.dx - playerSize.width / 2,
        rect.bottom - playerSize.height,
      );

  Checkpoint copy() {
    return Checkpoint(
      id: id,
      rect: rect,
      reached: reached,
      flash: flash,
      fake: fake,
      visible: visible,
      spawnOverride: spawnOverride,
    );
  }

  void update(double dt) {
    flash = math.max(0, flash - dt);
  }
}

/// A collectible coin for the shop economy. Rarely spawned on level load;
/// spins in place until the player picks it up.
class Coin {
  Coin({required this.id, required this.rect, this.value = 3});

  final String id;
  Rect rect;
  final int value;
  bool collected = false;
  double spin = 0;

  Coin copy() {
    final copy = Coin(id: id, rect: rect, value: value);
    copy.collected = collected;
    copy.spin = spin;
    return copy;
  }

  void update(double dt) {
    spin += dt * 5;
  }
}

/// A slick patch of floor: while the player overlaps it, horizontal
/// acceleration (and braking) drops to a fraction, so they slide. Always
/// visible — the trolling is in the physics, not the surprise.
class IceZone {
  IceZone({required this.id, required this.rect});

  final String id;
  final Rect rect;

  IceZone copy() => IceZone(id: id, rect: rect);
}

/// While the player is inside, the world is swallowed by darkness except a
/// light circle around the player, lantern glows at checkpoints, and glowing
/// goals. On FIRST entry the whole view stays lit for [previewDuration]
/// seconds — one good look, then it's flashlight only. The preview re-arms
/// when the level resets (each death grants a fresh look).
class DarkZone {
  DarkZone({
    required this.id,
    required this.rect,
    this.lightRadius = 140,
    this.previewDuration = 1.4,
  });

  final String id;
  final Rect rect;
  final double lightRadius;
  final double previewDuration;

  bool _entered = false;
  double _previewRemaining = 0;

  /// True during the one-time look around right after first entry.
  bool get revealing => _entered && _previewRemaining > 0;

  DarkZone copy() {
    return DarkZone(
      id: id,
      rect: rect,
      lightRadius: lightRadius,
      previewDuration: previewDuration,
    );
  }

  void update(double dt, Player player) {
    if (!_entered) {
      if (rect.overlaps(player.rect)) {
        _entered = true;
        _previewRemaining = previewDuration;
      }
      return;
    }
    if (_previewRemaining > 0) {
      _previewRemaining -= dt;
    }
  }
}

/// A region that inverts left/right input while the player is inside.
/// Invisible until first entered, then rendered as a tinted band.
class ReverseZone {
  ReverseZone({
    required this.id,
    required this.rect,
    this.revealed = false,
    this.flash = 0,
  });

  final String id;
  Rect rect;
  bool revealed;
  double flash;

  ReverseZone copy() {
    return ReverseZone(id: id, rect: rect, revealed: revealed, flash: flash);
  }

  void update(double dt) {
    flash = math.max(0, flash - dt);
  }
}

/// A short-lived debris particle spawned by the death effect.
class DeathParticle {
  DeathParticle({required this.position, required this.velocity});

  Offset position;
  Offset velocity;
  double life = 0.55;

  void update(double dt) {
    life -= dt;
    velocity += const Offset(0, 900) * dt;
    position += velocity * dt;
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

  /// A lethal body this trap currently projects into the world (the evil
  /// twin, the echo, ...). The engine kills the player on overlap; return
  /// null while the trap poses no touch danger.
  Rect? hazardRect(Player player) => null;

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

/// The level's decoy goal is a trap: touching it (or sneaking past it) makes
/// it vanish, reveals spikes at its base, and uncovers the real, previously
/// hidden goal further ahead.
class FakeGoalTrap extends Trap {
  FakeGoalTrap({required this.revealSpikeIds})
    : super(TrapTriggerType.playerProximity);

  final List<String> revealSpikeIds;

  @override
  void update(Level level, Player player, double dt) {
    final decoy = level.decoyGoal;
    if (decoy == null || triggered || !decoy.visible) {
      return;
    }
    final touched = player.rect.overlaps(decoy.rect.inflate(4));
    final passed = player.rect.left > decoy.rect.right + 24;
    if (!touched && !passed) {
      return;
    }
    triggered = true;
    decoy.visible = false;
    for (final id in revealSpikeIds) {
      final spike = level.spikeById(id);
      if (spike != null) {
        spike.visible = true;
        spike.dangerous = true;
        spike.flash = 0.7;
      }
    }
    level.goal.visible = true;
    level.goal.flash = 0.7;
  }

  @override
  Trap copy() {
    return FakeGoalTrap(revealSpikeIds: List.of(revealSpikeIds));
  }
}

/// Touching the decoy starts a second lap through a reconfigured level.
///
/// The first-lap route is hidden, the alternate route is revealed, selected
/// spikes are armed or disarmed, and the real goal replaces the decoy. The
/// player is returned to [returnPosition] with no carried momentum. A death
/// creates a fresh [Level], so [restoreSecondLap] reapplies the same object
/// state without needing to touch the decoy again.
class SecondLapTrap extends Trap {
  SecondLapTrap({
    required this.returnPosition,
    this.hidePlatformIds = const [],
    this.showPlatformIds = const [],
    this.armSpikeIds = const [],
    this.disarmSpikeIds = const [],
  }) : super(TrapTriggerType.playerProximity);

  final Offset returnPosition;
  final List<String> hidePlatformIds;
  final List<String> showPlatformIds;
  final List<String> armSpikeIds;
  final List<String> disarmSpikeIds;

  @override
  void update(Level level, Player player, double dt) {
    final decoy = level.decoyGoal;
    if (triggered || decoy == null || !decoy.visible) {
      return;
    }

    final touched = player.rect.overlaps(decoy.rect.inflate(4));
    final passed = player.rect.left > decoy.rect.right + 24;
    if (!touched && !passed) {
      return;
    }

    _applySecondLap(level, flash: true);
    player.position = returnPosition;
    player.velocity = Offset.zero;
    player.onGround = false;
    player.groundPlatformId = null;
  }

  /// Restores the persistent second-lap layout after the level was copied
  /// afresh following a death. The caller is responsible for spawning the
  /// player at [returnPosition].
  void restoreSecondLap(Level level) {
    _applySecondLap(level, flash: false);
  }

  void _applySecondLap(Level level, {required bool flash}) {
    triggered = true;
    final decoy = level.decoyGoal;
    if (decoy != null) {
      decoy.visible = false;
    }
    level.goal.visible = true;
    level.goal.flash = flash ? 0.7 : 0;

    for (final id in hidePlatformIds) {
      final platform = level.platformById(id);
      if (platform == null) {
        continue;
      }
      platform.visible = false;
      platform.solid = false;
      platform.active = false;
    }
    for (final id in showPlatformIds) {
      final platform = level.platformById(id);
      if (platform == null) {
        continue;
      }
      platform.visible = true;
      platform.solid = true;
      platform.flash = flash ? 0.7 : 0;
    }
    for (final id in armSpikeIds) {
      final spike = level.spikeById(id);
      if (spike == null) {
        continue;
      }
      spike.visible = true;
      spike.dangerous = true;
      spike.flash = flash ? 0.7 : 0;
    }
    for (final id in disarmSpikeIds) {
      final spike = level.spikeById(id);
      if (spike == null) {
        continue;
      }
      spike.dangerous = false;
      spike.velocity = Offset.zero;
      spike.targetLeft = null;
      spike.targetTop = null;
      spike.targetBottom = null;
      spike.flash = flash ? 0.7 : 0;
    }
  }

  @override
  Trap copy() {
    return SecondLapTrap(
      returnPosition: returnPosition,
      hidePlatformIds: List.of(hidePlatformIds),
      showPlatformIds: List.of(showPlatformIds),
      armSpikeIds: List.of(armSpikeIds),
      disarmSpikeIds: List.of(disarmSpikeIds),
    );
  }
}

/// A spike that, once woken, slides horizontally toward the player forever,
/// clamped to [minX, maxX]. It moves slightly slower than the player runs,
/// so it can be outrun or jumped over — but never ignored.
class ChasingSpikeTrap extends Trap {
  ChasingSpikeTrap({
    required this.spikeId,
    required this.triggerX,
    required this.minX,
    required this.maxX,
    this.speed = 200,
  }) : super(TrapTriggerType.playerXPosition);

  final String spikeId;
  final double triggerX;
  final double minX;
  final double maxX;
  final double speed;

  @override
  void update(Level level, Player player, double dt) {
    final spike = level.spikeById(spikeId);
    if (spike == null) {
      return;
    }
    if (!triggered) {
      if (player.center.dx < triggerX) {
        return;
      }
      triggered = true;
      spike.visible = true;
      spike.dangerous = true;
      spike.flash = 0.6;
    }
    final delta = player.center.dx - spike.rect.center.dx;
    if (delta.abs() < 1) {
      return;
    }
    final step = delta.sign * speed * dt;
    final newLeft = (spike.rect.left + step).clamp(minX, maxX);
    spike.rect = Rect.fromLTWH(
      newLeft,
      spike.rect.top,
      spike.rect.width,
      spike.rect.height,
    );
  }

  @override
  Trap copy() {
    return ChasingSpikeTrap(
      spikeId: spikeId,
      triggerX: triggerX,
      minX: minX,
      maxX: maxX,
      speed: speed,
    );
  }
}

/// A checkpoint-shaped lie. Touching the fake flag makes it vanish and
/// reveals spikes at its base — it never grants a spawn point. The player's
/// trust in checkpoints, weaponized.
class FakeCheckpointTrap extends Trap {
  FakeCheckpointTrap({required this.checkpointId, required this.revealSpikeIds})
    : super(TrapTriggerType.playerProximity);

  final String checkpointId;
  final List<String> revealSpikeIds;

  @override
  void update(Level level, Player player, double dt) {
    if (triggered) {
      return;
    }
    final checkpoint = level.checkpointById(checkpointId);
    if (checkpoint == null || !checkpoint.visible) {
      return;
    }
    if (!player.rect.overlaps(checkpoint.rect.inflate(4))) {
      return;
    }
    triggered = true;
    checkpoint.visible = false;
    for (final id in revealSpikeIds) {
      final spike = level.spikeById(id);
      if (spike != null) {
        spike.visible = true;
        spike.dangerous = true;
        spike.flash = 0.7;
      }
    }
  }

  @override
  Trap copy() {
    return FakeCheckpointTrap(
      checkpointId: checkpointId,
      revealSpikeIds: List.of(revealSpikeIds),
    );
  }
}

/// The finale gag: the decoy goal retreats [retreats] times as the player
/// approaches, then breaks into a run, sprints past [cliffX], plummets off
/// the edge — and the real, hidden goal reveals itself back at the last
/// checkpoint.
class FleeingGoalTrap extends Trap {
  FleeingGoalTrap({
    required this.cliffX,
    this.triggerDistance = 90,
    this.retreatDistance = 90,
    this.retreats = 2,
    this.retreatSpeed = 300,
    this.fleeSpeed = 320,
  }) : super(TrapTriggerType.playerProximity);

  final double cliffX;
  final double triggerDistance;
  final double retreatDistance;
  final int retreats;
  final double retreatSpeed;
  final double fleeSpeed;

  int _retreatsDone = 0;
  bool _fleeing = false;
  double _fallSpeed = 0;

  @override
  void update(Level level, Player player, double dt) {
    final decoy = level.decoyGoal;
    if (decoy == null || !decoy.visible) {
      return;
    }

    if (_fleeing) {
      var dy = 0.0;
      if (decoy.rect.left > cliffX) {
        _fallSpeed += 1400 * dt;
        dy = _fallSpeed * dt;
      }
      decoy.rect = decoy.rect.shift(Offset(fleeSpeed * dt, dy));
      if (decoy.rect.top > worldHeight + 80) {
        decoy.visible = false;
        level.goal.visible = true;
        level.goal.flash = 0.8;
      }
      return;
    }

    // Wait until the decoy has finished its previous retreat before the
    // next approach can set it off again.
    if (decoy.velocity != Offset.zero) {
      return;
    }
    final close = player.rect.right >= decoy.rect.left - triggerDistance;
    if (!close) {
      return;
    }

    triggered = true;
    if (_retreatsDone < retreats) {
      _retreatsDone++;
      decoy.velocity = Offset(retreatSpeed, 0);
      decoy.targetLeft = decoy.rect.left + retreatDistance;
      decoy.flash = 0.5;
    } else {
      _fleeing = true;
      decoy.flash = 0.6;
    }
  }

  @override
  Trap copy() {
    return FleeingGoalTrap(
      cliffX: cliffX,
      triggerDistance: triggerDistance,
      retreatDistance: retreatDistance,
      retreats: retreats,
      retreatSpeed: retreatSpeed,
      fleeSpeed: fleeSpeed,
    );
  }
}

/// Red light, green light: a spike that slides toward the player at a
/// fraction of the player's OWN current speed — and freezes the instant
/// they stop. Your movement is what feeds it.
class MimicSpikeTrap extends Trap {
  MimicSpikeTrap({
    required this.spikeId,
    required this.triggerX,
    required this.minX,
    required this.maxX,
    this.speedFactor = 0.9,
  }) : super(TrapTriggerType.playerXPosition);

  final String spikeId;
  final double triggerX;
  final double minX;
  final double maxX;
  final double speedFactor;

  @override
  void update(Level level, Player player, double dt) {
    final spike = level.spikeById(spikeId);
    if (spike == null) {
      return;
    }
    if (!triggered) {
      if (player.center.dx < triggerX) {
        return;
      }
      triggered = true;
      spike.flash = 0.5;
    }
    final playerSpeed = player.velocity.dx.abs();
    if (playerSpeed < 5) {
      return; // You freeze, it freezes.
    }
    final delta = player.center.dx - spike.rect.center.dx;
    if (delta.abs() < 1) {
      return;
    }
    final step = delta.sign * playerSpeed * speedFactor * dt;
    final newLeft = (spike.rect.left + step).clamp(minX, maxX);
    spike.rect = Rect.fromLTWH(
      newLeft,
      spike.rect.top,
      spike.rect.width,
      spike.rect.height,
    );
  }

  @override
  Trap copy() {
    return MimicSpikeTrap(
      spikeId: spikeId,
      triggerX: triggerX,
      minX: minX,
      maxX: maxX,
      speedFactor: speedFactor,
    );
  }
}

/// A hostile mirror image of the player. While the player is within [range]
/// of [mirrorX], the twin stands at the player's position reflected across
/// that line — walk toward it and it walks toward you. It stays on the
/// ground, so the only way past is over its head, timed through the meeting
/// point at the mirror line. Touching it is death (the engine checks
/// [twinRect] during hazard collision; the painter draws it).
class EvilTwinTrap extends Trap {
  EvilTwinTrap({required this.mirrorX, this.range = 400})
    : super(TrapTriggerType.playerProximity);

  final double mirrorX;
  final double range;

  Rect? twinRect(Player player) {
    if ((player.center.dx - mirrorX).abs() > range) {
      return null;
    }
    final twinCenterX = 2 * mirrorX - player.center.dx;
    return Rect.fromLTWH(
      twinCenterX - playerSize.width / 2,
      floorY - playerSize.height,
      playerSize.width,
      playerSize.height,
    );
  }

  @override
  Rect? hazardRect(Player player) => twinRect(player);

  @override
  void update(Level level, Player player, double dt) {
    if (!triggered && twinRect(player) != null) {
      triggered = true; // The twin steps out of the mirror: play the sting.
    }
  }

  @override
  Trap copy() {
    return EvilTwinTrap(mirrorX: mirrorX, range: range);
  }
}

/// Schrödinger's bridge: two platform worlds, exactly one of them real.
/// Every NORMAL jump toggles which one — the active group turns ghostly the
/// moment the player leaves the ground, and the other solidifies. Jump-pad
/// launches are not jumps and deliberately do not toggle.
///
/// The toggle is fully deterministic: same number of jumps, same world.
/// Hopping in place on neutral ground is a legitimate way to set parity —
/// hopping on a quantum platform, however, dissolves it beneath you.
class QuantumSwapTrap extends Trap {
  QuantumSwapTrap({required this.groupA, required this.groupB})
    : super(TrapTriggerType.playerJump);

  final List<String> groupA;
  final List<String> groupB;

  /// Level data starts with group A solid and group B ghosted.
  bool aActive = true;

  @override
  void onPlayerJump(Level level, Player player) {
    triggered = true;
    aActive = !aActive;
    _apply(level, groupA, solid: aActive);
    _apply(level, groupB, solid: !aActive);
  }

  void _apply(Level level, List<String> ids, {required bool solid}) {
    for (final id in ids) {
      final platform = level.platformById(id);
      if (platform == null) {
        continue;
      }
      platform.solid = solid;
      platform.ghost = !solid;
      platform.flash = 0.3;
    }
  }

  @override
  Trap copy() {
    return QuantumSwapTrap(groupA: List.of(groupA), groupB: List.of(groupB));
  }
}

/// A translucent copy of the player that replays their own movement with a
/// fixed [delay]. Harmless in the starting room; past [armX] it glows red
/// and kills on touch. Standing still lets your own past catch up with you.
///
/// The trail records positions the player actually occupied, so the echo
/// can never clip through anything the player didn't. It resets whenever
/// the level does, and the engine clears it on every checkpoint capture so
/// a fresh section starts with a fresh echo.
class EchoTrap extends Trap {
  EchoTrap({this.delay = 1.2, required this.armX})
    : super(TrapTriggerType.playerProximity);

  final double delay;
  final double armX;

  double _time = 0;
  final List<(double, Offset)> _trail = [];

  /// Where the echo currently stands, or null while the trail is still
  /// shorter than [delay].
  Rect? get echoRect {
    final target = _time - delay;
    if (target < 0 || _trail.isEmpty || _trail.first.$1 > target) {
      return null;
    }
    var position = _trail.first.$2;
    for (final (t, p) in _trail) {
      if (t > target) {
        break;
      }
      position = p;
    }
    return position & playerSize;
  }

  /// The echo is only lethal once it has itself crossed the arming line.
  bool get echoDeadly {
    final rect = echoRect;
    return rect != null && rect.center.dx > armX;
  }

  void clearTrail() {
    _trail.clear();
    _time = 0;
  }

  @override
  void update(Level level, Player player, double dt) {
    _time += dt;
    _trail.add((_time, player.position));
    while (_trail.length > 1 && _trail[1].$1 <= _time - delay) {
      _trail.removeAt(0);
    }
    if (!triggered && player.center.dx > armX) {
      triggered = true; // The boundary sting: your past is now hostile.
    }
  }

  @override
  Rect? hazardRect(Player player) => echoDeadly ? echoRect : null;

  @override
  Trap copy() {
    return EchoTrap(delay: delay, armX: armX);
  }
}
