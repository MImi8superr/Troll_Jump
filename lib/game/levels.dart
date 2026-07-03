import 'package:flutter/material.dart';

import 'models.dart';

List<Level> buildLevels() {
  return [
    Level(
      number: 1,
      title: 'First Steps',
      width: 1100,
      playerStart: _start(),
      platforms: [_ground('ground', 0, 1100)],
      spikes: [_upSpike('spike', 470)],
      goal: _goal(1000),
    ),
    Level(
      number: 2,
      title: 'Bait and Wait',
      width: 1250,
      playerStart: _start(),
      platforms: [_ground('ground', 0, 1250)],
      spikes: [_upSpike('bait-spike', 520)],
      goal: _goal(1140),
      traps: [
        SlideSpikeTrap(
          spikeId: 'bait-spike',
          triggerDistance: 108,
          moveDistance: 118,
          speed: 420,
        ),
      ],
    ),
    Level(
      number: 3,
      title: 'Short Visit',
      width: 1250,
      playerStart: _start(),
      platforms: [
        _ground('left-ground', 0, 410),
        _ground('right-ground', 660, 590),
        _platform('vanish', 455, 430, 150, cracked: true),
      ],
      spikes: [],
      goal: _goal(1140),
      traps: [DisappearPlatformTrap(platformId: 'vanish', delay: 0.55)],
    ),
    Level(
      number: 4,
      title: 'Look Up',
      width: 1200,
      playerStart: _start(),
      platforms: [_ground('ground', 0, 1200)],
      spikes: [_downSpike('drop-spike', 570, 118)],
      goal: _goal(1080),
      traps: [DropSpikeTrap(spikeId: 'drop-spike', triggerX: 500)],
    ),
    Level(
      number: 5,
      title: 'Almost There',
      width: 1280,
      playerStart: _start(),
      platforms: [_ground('ground', 0, 1280)],
      spikes: [_upSpike('small-spike', 500)],
      goal: _goal(930),
      traps: [
        GoalRetreatTrap(triggerDistance: 110, retreatDistance: 165, speed: 280),
      ],
    ),
    Level(
      number: 6,
      title: 'Jump Starts It',
      width: 1300,
      playerStart: _start(),
      platforms: [
        _ground('left-ground', 0, 390),
        _ground('right-ground', 840, 460),
        _platform('mover', 430, 430, 150),
      ],
      spikes: [],
      goal: _goal(1180),
      traps: [
        ActivateMovingPlatformTrap(
          platformId: 'mover',
          speed: 150,
          minX: 430,
          maxX: 670,
        ),
      ],
    ),
    Level(
      number: 7,
      title: 'Something Underfoot',
      width: 1200,
      playerStart: _start(),
      platforms: [_ground('ground', 0, 1200)],
      spikes: [
        _hiddenUpSpike('hidden-spike', 590),
        _upSpike('visible-spike', 820),
      ],
      goal: _goal(1080),
      traps: [RevealSpikeTrap(spikeId: 'hidden-spike', triggerDistance: 115)],
    ),
    Level(
      number: 8,
      title: 'Cracked Floor',
      width: 1250,
      playerStart: _start(),
      platforms: [
        _ground('left-ground', 0, 440),
        _platform('fake-floor', 440, floorY, 170, height: 80, cracked: true),
        _ground('right-ground', 610, 640),
      ],
      spikes: [],
      goal: _goal(1130),
      traps: [
        BreakPlatformTrap(platformId: 'fake-floor', triggerX: 430, delay: 0.24),
      ],
    ),
    Level(
      number: 9,
      title: 'Spring Manners',
      width: 1250,
      playerStart: _start(),
      platforms: [
        _ground('left-ground', 0, 500),
        _ground('right-ground', 760, 490),
      ],
      spikes: [
        _downSpike('ceiling-1', 520, 238),
        _downSpike('ceiling-2', 575, 238),
      ],
      jumpPads: [
        JumpPad(
          id: 'wild-pad',
          rect: const Rect.fromLTWH(528, floorY - 14, 72, 14),
          gentleVelocity: -515,
          wildVelocity: -830,
          speedThreshold: 145,
        ),
      ],
      goal: _goal(1130),
    ),
    Level(
      number: 10,
      title: 'Shy Platform',
      width: 1300,
      playerStart: _start(),
      platforms: [
        _ground('left-ground', 0, 460),
        _ground('right-ground', 820, 480),
        _platform('shy-platform', 500, 430, 130),
      ],
      spikes: [],
      goal: _goal(1180),
      traps: [
        FleePlatformOnJumpTrap(
          platformId: 'shy-platform',
          triggerDistance: 280,
          moveDistance: 115,
          speed: 310,
        ),
      ],
    ),
    Level(
      number: 11,
      title: 'Looks Can Hurt',
      width: 1150,
      playerStart: _start(),
      platforms: [_ground('ground', 0, 1150)],
      spikes: [
        _upSpike('fake-spike', 430, dangerous: false),
        _upSpike('real-spike', 820),
      ],
      hazards: [
        HazardBlock(
          id: 'normal-looking-danger',
          rect: const Rect.fromLTWH(610, floorY - 36, 46, 36),
        ),
      ],
      goal: _goal(1040),
    ),
    Level(
      number: 12,
      title: 'Step Back',
      width: 1200,
      playerStart: _start(170),
      platforms: [_ground('ground', 0, 1200)],
      spikes: [
        _hiddenUpSpike('straight-trap', 350),
        _upSpike('late-spike', 745),
      ],
      goal: _goal(1080),
      traps: [
        ReverseFirstTrap(spikeId: 'straight-trap', disarmX: 70, triggerX: 340),
      ],
    ),
    Level(
      number: 13,
      title: 'Stacked Tricks',
      width: 1450,
      playerStart: _start(),
      platforms: [
        _ground('left-ground', 0, 370),
        _platform('fade-one', 420, 430, 150, cracked: true),
        _platform('fade-two', 690, 390, 150, cracked: true),
        _ground('right-ground', 930, 520),
      ],
      spikes: [_upSpike('runner-spike', 1060)],
      goal: _goal(1320),
      traps: [
        DisappearPlatformTrap(platformId: 'fade-one', delay: 0.5),
        DisappearPlatformTrap(platformId: 'fade-two', delay: 0.5),
        SlideSpikeTrap(
          spikeId: 'runner-spike',
          triggerDistance: 95,
          moveDistance: 95,
          speed: 380,
        ),
      ],
    ),
    Level(
      number: 14,
      title: 'Timing Window',
      width: 1500,
      playerStart: _start(),
      platforms: [
        _ground('left-ground', 0, 360),
        _platform('timed-platform', 400, 445, 130),
        _ground('middle-ground', 760, 400),
        _platform('late-floor', 1160, floorY, 150, height: 80, cracked: true),
        _ground('finish-ground', 1310, 190),
      ],
      spikes: [
        _downSpike('drop-one', 870, 130),
        _hiddenUpSpike('hidden-one', 1040),
      ],
      goal: _goal(1390),
      traps: [
        ActivateMovingPlatformTrap(
          platformId: 'timed-platform',
          speed: 170,
          minX: 400,
          maxX: 620,
        ),
        DropSpikeTrap(spikeId: 'drop-one', triggerX: 815),
        RevealSpikeTrap(spikeId: 'hidden-one', triggerDistance: 115),
        BreakPlatformTrap(
          platformId: 'late-floor',
          triggerX: 1145,
          delay: 0.28,
        ),
      ],
    ),
    Level(
      number: 15,
      title: 'Final Mix',
      width: 1650,
      playerStart: _start(),
      platforms: [
        _ground('left-ground', 0, 390),
        _platform('last-fade', 440, 430, 150, cracked: true),
        _ground('middle-ground', 650, 330),
        _platform('last-shy', 1010, 430, 130),
        _ground('right-ground', 1240, 410),
      ],
      spikes: [
        _upSpike('early-bait', 285),
        _hiddenUpSpike('last-hidden', 765),
        _downSpike('last-drop', 1325, 120),
      ],
      goal: _goal(1450),
      traps: [
        SlideSpikeTrap(
          spikeId: 'early-bait',
          triggerDistance: 100,
          moveDistance: 85,
          speed: 390,
        ),
        DisappearPlatformTrap(platformId: 'last-fade', delay: 0.52),
        RevealSpikeTrap(spikeId: 'last-hidden', triggerDistance: 110),
        FleePlatformOnJumpTrap(
          platformId: 'last-shy',
          triggerDistance: 260,
          moveDistance: 115,
          speed: 300,
        ),
        DropSpikeTrap(spikeId: 'last-drop', triggerX: 1280),
        GoalRetreatTrap(triggerDistance: 95, retreatDistance: 105, speed: 250),
      ],
    ),
  ];
}

Offset _start([double x = 64]) {
  return Offset(x, floorY - playerSize.height);
}

Platform _ground(String id, double x, double width) {
  return Platform(
    id: id,
    rect: Rect.fromLTWH(x, floorY, width, worldHeight - floorY),
  );
}

Platform _platform(
  String id,
  double x,
  double y,
  double width, {
  double height = 22,
  bool cracked = false,
}) {
  return Platform(
    id: id,
    rect: Rect.fromLTWH(x, y, width, height),
    color: cracked ? const Color(0xFF4B5563) : const Color(0xFF263238),
    cracked: cracked,
  );
}

Spike _upSpike(
  String id,
  double x, {
  bool visible = true,
  bool dangerous = true,
}) {
  return Spike(
    id: id,
    rect: Rect.fromLTWH(x, floorY - 36, 40, 36),
    visible: visible,
    dangerous: dangerous,
  );
}

Spike _hiddenUpSpike(String id, double x) {
  return _upSpike(id, x, visible: false, dangerous: false);
}

Spike _downSpike(String id, double x, double y) {
  return Spike(
    id: id,
    rect: Rect.fromLTWH(x, y, 42, 38),
    direction: SpikeDirection.down,
  );
}

Goal _goal(double x) {
  return Goal(rect: Rect.fromLTWH(x, floorY - 86, 54, 86));
}
