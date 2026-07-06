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
      checkpoints: [_checkpoint('cp-13', 960)],
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
      checkpoints: [_checkpoint('cp-14', 790)],
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
      checkpoints: [_checkpoint('cp-15', 690)],
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
    Level(
      number: 16,
      title: 'Mirror Rules',
      width: 1500,
      playerStart: _start(),
      platforms: [
        _ground('ground', 0, 1500),
        // Two identical-looking walls: the low one is real (jump it), the
        // tall "impossible" one is fake — walk straight through.
        _wall('wall-real', 400, 88),
        _wall('wall-fake', 560, 150, solid: false),
      ],
      spikes: [_upSpike('chaser-16', 1330)],
      reverseZones: [_reverseZone('rz-16', 700, 320)],
      goal: _goal(1430),
      traps: [
        ChasingSpikeTrap(
          spikeId: 'chaser-16',
          triggerX: 1060,
          minX: 1020,
          maxX: 1340,
        ),
      ],
    ),
    Level(
      number: 17,
      title: 'The Wrong Exit',
      width: 1600,
      playerStart: _start(),
      platforms: [_ground('ground', 0, 1600)],
      spikes: [
        _upSpike('warm-17', 380),
        _hiddenUpSpike('fake-goal-spike-1', 968),
        _hiddenUpSpike('fake-goal-spike-2', 1012),
        _upSpike('slide-17', 1240),
      ],
      checkpoints: [_checkpoint('cp-17', 620)],
      decoyGoal: Goal(rect: const Rect.fromLTWH(1000, floorY - 86, 54, 86)),
      goal: _goal(1470, visible: false),
      traps: [
        FakeGoalTrap(
          revealSpikeIds: ['fake-goal-spike-1', 'fake-goal-spike-2'],
        ),
        SlideSpikeTrap(
          spikeId: 'slide-17',
          triggerDistance: 100,
          moveDistance: 90,
          speed: 400,
        ),
      ],
    ),
    Level(
      number: 18,
      title: 'Leap of Faith',
      width: 1700,
      // The run starts on an elevated block; the pit below is the real path.
      playerStart: Offset(64, 340 - playerSize.height),
      platforms: [
        _platform('start-block', 0, 340, 300, height: 260),
        _platform('bridge-1', 340, 340, 160),
        _platform('bridge-2', 560, 340, 160, cracked: true),
        _platform('bridge-3', 780, 340, 160),
        _ground('pit-floor', 300, 900),
        _platform('right-block', 1200, 340, 500, height: 260),
      ],
      spikes: [
        // The pit is paved with spikes — every single one of them fake.
        // Eighteen levels of "spikes kill" collide with one leap of faith.
        _upSpike('faith-1', 330, dangerous: false),
        _upSpike('faith-2', 420, dangerous: false),
        _upSpike('faith-3', 500, dangerous: false),
        _upSpike('faith-4', 640, dangerous: false),
        _upSpike('faith-5', 700, dangerous: false),
        _upSpike('faith-6', 960, dangerous: false),
        _upSpike('faith-7', 1030, dangerous: false),
        // The ceiling spikes under the bridge, however, are very real:
        // a full jump in the corridor is lethal — short hops only.
        _downSpike('ceil-1', 400, 362),
        _downSpike('ceil-3', 795, 362),
        _downSpike('ceil-4', 866, 362),
        // One last fake spike on the exit plateau as a farewell wink.
        Spike(
          id: 'roof-fake',
          rect: const Rect.fromLTWH(1400, 340 - 36, 40, 36),
          dangerous: false,
        ),
      ],
      hazards: [
        HazardBlock(
          id: 'hazard-18',
          rect: const Rect.fromLTWH(870, floorY - 36, 46, 36),
        ),
      ],
      jumpPads: [
        // Only the wild bounce (land on it with speed) clears the 180px wall
        // — the exact opposite of level 9's "be gentle" lesson.
        JumpPad(
          id: 'launch-18',
          rect: const Rect.fromLTWH(1110, floorY - 14, 72, 14),
        ),
      ],
      checkpoints: [_checkpoint('cp-18', 590)],
      goal: Goal(rect: const Rect.fromLTWH(1620, 340 - 86, 54, 86)),
      traps: [
        BreakPlatformTrap(platformId: 'bridge-2', triggerX: 570, delay: 0.22),
      ],
    ),
    Level(
      number: 19,
      title: 'Thin Ice',
      width: 1800,
      playerStart: _start(),
      platforms: [
        _ground('g-19a', 0, 820),
        _ground('g-19b', 990, 810),
      ],
      spikes: [
        // Slides TOWARD the player, parking right at the edge of the ice.
        _upSpike('ice-bait', 700),
        _upSpike('chaser-19', 1490),
        _hiddenUpSpike('fc-spike-1', 1470),
        _hiddenUpSpike('fc-spike-2', 1512),
        _downSpike('last-drop-19', 1685, 120),
      ],
      iceZones: [
        _iceZone('ice-a', 300, 320),
        _iceZone('ice-b', 1050, 350),
      ],
      checkpoints: [
        _checkpoint('cp-19a', 770),
        // Looks exactly like a checkpoint. Is not a checkpoint.
        Checkpoint(
          id: 'cp-19-fake',
          rect: const Rect.fromLTWH(1500, floorY - 58, 34, 58),
          fake: true,
        ),
        _checkpoint('cp-19b', 1615),
      ],
      goal: _goal(1730),
      traps: [
        SlideSpikeTrap(
          spikeId: 'ice-bait',
          triggerDistance: 130,
          moveDistance: -80,
          speed: -360,
        ),
        ChasingSpikeTrap(
          spikeId: 'chaser-19',
          triggerX: 1150,
          minX: 1120,
          maxX: 1420,
        ),
        FakeCheckpointTrap(
          checkpointId: 'cp-19-fake',
          revealSpikeIds: ['fc-spike-1', 'fc-spike-2'],
        ),
        DropSpikeTrap(spikeId: 'last-drop-19', triggerX: 1655),
      ],
    ),
    Level(
      number: 20,
      title: 'Troll Parade',
      width: 2600,
      playerStart: _start(),
      platforms: [
        _ground('g-20a', 0, 350),
        _platform('fade-20a', 390, 430, 130, cracked: true),
        _platform('fade-20b', 590, 430, 130, cracked: true),
        _ground('g-20b', 760, 390),
        _platform('shy-20', 1200, 430, 130),
        _ground('g-20c', 1500, 200),
        _wall('wall-real-20', 1580, 88),
        _wall('wall-fake-20', 1640, 150, solid: false),
        _ground('g-20d', 1700, 660),
      ],
      spikes: [
        _upSpike('bait-20', 250),
        _downSpike('drop-20a', 850, 110),
        _downSpike('drop-20b', 1000, 110),
        _upSpike('chaser-20', 1980),
      ],
      reverseZones: [_reverseZone('rz-20', 1500, 200)],
      checkpoints: [
        _checkpoint('cp-20a', 1120),
        _checkpoint('cp-20b', 1760),
      ],
      // The flag everyone sees is the decoy; the real goal hides back at
      // the last checkpoint and only appears once the decoy takes the dive.
      decoyGoal: Goal(rect: const Rect.fromLTWH(2120, floorY - 86, 54, 86)),
      goal: _goal(1705, visible: false),
      traps: [
        SlideSpikeTrap(
          spikeId: 'bait-20',
          triggerDistance: 100,
          moveDistance: 60,
          speed: 380,
        ),
        DisappearPlatformTrap(platformId: 'fade-20a', delay: 0.45),
        DisappearPlatformTrap(platformId: 'fade-20b', delay: 0.45),
        DropSpikeTrap(spikeId: 'drop-20a', triggerX: 800),
        DropSpikeTrap(spikeId: 'drop-20b', triggerX: 950),
        FleePlatformOnJumpTrap(
          platformId: 'shy-20',
          triggerDistance: 200,
          moveDistance: 80,
          speed: 300,
        ),
        ChasingSpikeTrap(
          spikeId: 'chaser-20',
          triggerX: 1850,
          minX: 1820,
          maxX: 2000,
        ),
        FleeingGoalTrap(cliffX: 2360),
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

Goal _goal(double x, {bool visible = true}) {
  return Goal(rect: Rect.fromLTWH(x, floorY - 86, 54, 86), visible: visible);
}

Checkpoint _checkpoint(String id, double x) {
  return Checkpoint(id: id, rect: Rect.fromLTWH(x, floorY - 58, 34, 58));
}

ReverseZone _reverseZone(String id, double x, double width) {
  return ReverseZone(id: id, rect: Rect.fromLTWH(x, floorY - 170, width, 170));
}

IceZone _iceZone(String id, double x, double width) {
  // A thin sheet sitting on the floor: slippery only while the player's
  // feet are in it, so jumping briefly restores full air control.
  return IceZone(id: id, rect: Rect.fromLTWH(x, floorY - 24, width, 24));
}

Platform _wall(String id, double x, double height, {bool solid = true}) {
  return Platform(
    id: id,
    rect: Rect.fromLTWH(x, floorY - height, 26, height),
    color: const Color(0xFF37474F),
    solid: solid,
  );
}
