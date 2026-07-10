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
    Level(
      number: 21,
      title: 'Trollhalla',
      width: 2650,
      playerStart: _start(),
      platforms: [
        _ground('g-21a', 0, 1310),
        _ground('g-21b', 1470, 1180),
        _wall('wall-short-21', 1880, 88),
        _wall('wall-tall-21', 2110, 170),
      ],
      spikes: [
        // The crowd: a dense carpet of fake spikes (level 18 taught that
        // walking through is safe) — but ONE of them is real, identical,
        // and hunts the player through the crowd. Spot the mover.
        _upSpike('f21-1', 300, dangerous: false),
        _upSpike('f21-2', 335, dangerous: false),
        _upSpike('f21-3', 370, dangerous: false),
        _upSpike('f21-4', 405, dangerous: false),
        _upSpike('f21-5', 440, dangerous: false),
        _upSpike('chaser-21', 460),
        _upSpike('f21-6', 495, dangerous: false),
        _upSpike('f21-7', 530, dangerous: false),
        _upSpike('f21-8', 565, dangerous: false),
        _upSpike('f21-9', 600, dangerous: false),
        // Drop-spike rain: keep sprinting — straight onto the ice.
        _downSpike('d21-a', 840, 110),
        _downSpike('d21-b', 960, 110),
        _downSpike('d21-c', 1060, 110),
        // Inside the overlapping ice + reverse zone.
        _upSpike('mirror-spike-21', 1780),
        // Under the fake checkpoint.
        _hiddenUpSpike('fc21-a', 2200),
        _hiddenUpSpike('fc21-b', 2244),
        // Under the fake goal.
        _hiddenUpSpike('fg21-a', 2450),
        _hiddenUpSpike('fg21-b', 2494),
      ],
      iceZones: [
        _iceZone('ice-21a', 1100, 210),
        _iceZone('ice-21b', 1620, 210),
      ],
      // Overlaps ice-21b: mirrored controls while sliding.
      reverseZones: [_reverseZone('rz-21', 1600, 250)],
      jumpPads: [
        // The only way over the tall wall: land on it with speed (wild).
        JumpPad(
          id: 'launch-21',
          rect: const Rect.fromLTWH(1990, floorY - 14, 72, 14),
        ),
      ],
      checkpoints: [
        _checkpoint('cp-21a', 720),
        // Floating over the pit: grabbed mid-jump. Respawns on the far
        // ledge — a flag in the air is no place to wake up.
        Checkpoint(
          id: 'cp-21air',
          rect: const Rect.fromLTWH(1375, 375, 34, 58),
          spawnOverride: Offset(1490, floorY - playerSize.height),
        ),
        _checkpoint('cp-21c', 2150),
        // Level 19 taught "the first checkpoint is the fake one".
        // Here the first is real — and this second one is not.
        Checkpoint(
          id: 'cp-21fake',
          rect: const Rect.fromLTWH(2230, floorY - 58, 34, 58),
          fake: true,
        ),
      ],
      decoyGoal: Goal(rect: const Rect.fromLTWH(2480, floorY - 86, 54, 86)),
      // The real goal has been standing at the start the whole time.
      goal: _goal(90, visible: false),
      traps: [
        ChasingSpikeTrap(
          spikeId: 'chaser-21',
          triggerX: 250,
          minX: 290,
          maxX: 640,
          speed: 190,
        ),
        DropSpikeTrap(spikeId: 'd21-a', triggerX: 790),
        DropSpikeTrap(spikeId: 'd21-b', triggerX: 910),
        DropSpikeTrap(spikeId: 'd21-c', triggerX: 1010),
        FakeCheckpointTrap(
          checkpointId: 'cp-21fake',
          revealSpikeIds: ['fc21-a', 'fc21-b'],
        ),
        // Both walls crumble as the player nears the fake goal — ominous,
        // and it opens the way back.
        BreakPlatformTrap(
          platformId: 'wall-short-21',
          triggerX: 2440,
          delay: 0.3,
        ),
        BreakPlatformTrap(
          platformId: 'wall-tall-21',
          triggerX: 2440,
          delay: 0.3,
        ),
        FakeGoalTrap(revealSpikeIds: ['fg21-a', 'fg21-b']),
      ],
    ),
    Level(
      number: 22,
      title: 'Mirror Match',
      width: 2400,
      playerStart: _start(),
      platforms: [
        _ground('ground', 0, 2400),
        // A low roof over the mimic corridor: its ceiling spikes make full
        // jumps lethal, so the mimic must be cleared with measured hops.
        _platform('roof-22a', 420, 310, 220),
        _platform('roof-22b', 700, 310, 220),
        _platform('roof-22c', 980, 310, 140),
      ],
      spikes: [
        _upSpike('warm-22', 300),
        // Red light, green light: moves only while YOU move.
        _upSpike('mimic-22', 1000),
        _downSpike('lid-22a', 440, 332),
        _downSpike('lid-22b', 520, 332),
        _downSpike('lid-22c', 600, 332),
        _downSpike('lid-22d', 720, 332),
        _downSpike('lid-22e', 800, 332),
        _downSpike('lid-22f', 880, 332),
        _downSpike('lid-22g', 1000, 332),
        _downSpike('lid-22h', 1060, 332),
        // The twin arena: two spikes mirrored around x=1625.
        _upSpike('arena-22a', 1450),
        _upSpike('arena-22b', 1800),
      ],
      reverseZones: [_reverseZone('rz-22', 1650, 250)],
      checkpoints: [
        _checkpoint('cp-22a', 380),
        _checkpoint('cp-22b', 1180),
        _checkpoint('cp-22c', 2020),
      ],
      goal: _goal(2250),
      traps: [
        MimicSpikeTrap(
          spikeId: 'mimic-22',
          triggerX: 430,
          minX: 460,
          maxX: 1010,
          speedFactor: 0.55,
        ),
        EvilTwinTrap(mirrorX: 1625),
        GoalRetreatTrap(triggerDistance: 90, retreatDistance: 90, speed: 260),
      ],
    ),
    Level(
      number: 23,
      title: 'Lights Out',
      width: 2500,
      playerStart: _start(),
      platforms: [
        _ground('g-23a', 0, 1020),
        _ground('g-23b', 1160, 1340),
      ],
      spikes: [
        _upSpike('warm-23', 380),
        // The slalom, memorized by lightning.
        _upSpike('dark-23a', 650),
        _upSpike('dark-23b', 800),
        _upSpike('dark-23c', 950),
        // The hunter in the dark: visible only inside the light circle.
        _upSpike('hunter-23', 1750),
        _downSpike('drop-23', 2130, 110),
        // Under the glowing decoy.
        _hiddenUpSpike('fg23-a', 2170),
        _hiddenUpSpike('fg23-b', 2214),
      ],
      darkZones: [_darkZone('dz-23', 500, 1900)],
      checkpoints: [
        // Lanterns: each checkpoint glows through the darkness.
        _checkpoint('cp-23a', 560),
        _checkpoint('cp-23b', 1200),
        _checkpoint('cp-23c', 1950),
      ],
      // The inviting glow in the deep dark is, of course, a lie.
      decoyGoal: Goal(rect: const Rect.fromLTWH(2200, floorY - 86, 54, 86)),
      goal: _goal(2050, visible: false),
      traps: [
        ChasingSpikeTrap(
          spikeId: 'hunter-23',
          triggerX: 1250,
          minX: 1230,
          maxX: 1780,
          speed: 185,
        ),
        DropSpikeTrap(spikeId: 'drop-23', triggerX: 2065),
        FakeGoalTrap(revealSpikeIds: ['fg23-a', 'fg23-b']),
      ],
    ),
    // Level 18's leap of faith, replayed blind: the bridge breaks in the
    // dark, the spike carpet below is (mostly) a lie, a hunter hides in the
    // crowd, and the friendliest light in the darkness is a fake lantern.
    Level(
      number: 24,
      title: 'Blind Faith',
      width: 2700,
      playerStart: Offset(64, 380 - playerSize.height),
      platforms: [
        _platform('start-block-24', 0, 380, 560, height: 220),
        _platform('br-24a', 620, 380, 160),
        _platform('br-24b', 840, 380, 160, cracked: true),
        _ground('pit-floor-24', 560, 900),
        _platform('rb-24a', 1460, 340, 740, height: 260),
        _platform('rb-24b', 2340, 340, 360, height: 260),
      ],
      spikes: [
        // The carpet of lies on the pit floor.
        _upSpike('bf-1', 600, dangerous: false),
        _upSpike('bf-2', 660, dangerous: false),
        _upSpike('bf-3', 720, dangerous: false),
        _upSpike('bf-4', 790, dangerous: false),
        _upSpike('bf-5', 860, dangerous: false),
        _upSpike('bf-6', 930, dangerous: false),
        _upSpike('bf-7', 1060, dangerous: false),
        _upSpike('bf-8', 1120, dangerous: false),
        _upSpike('bf-9', 1240, dangerous: false),
        // Hidden in the crowd, woken in the dark: the hunter.
        _upSpike('chaser-24', 1100),
        // Under the fake lantern on the upper ledge.
        Spike(
          id: 'fl-24a',
          rect: const Rect.fromLTWH(1670, 340 - 36, 40, 36),
          visible: false,
          dangerous: false,
        ),
        Spike(
          id: 'fl-24b',
          rect: const Rect.fromLTWH(1714, 340 - 36, 40, 36),
          visible: false,
          dangerous: false,
        ),
      ],
      jumpPads: [
        // The wild bounce out of the pit, aimed in the dark.
        JumpPad(
          id: 'launch-24',
          rect: const Rect.fromLTWH(1330, floorY - 14, 72, 14),
        ),
      ],
      iceZones: [
        // An ice sheet on the upper ledge, sliding toward the gap — blind.
        IceZone(id: 'ice-24', rect: const Rect.fromLTWH(1900, 340 - 24, 300, 24)),
      ],
      darkZones: [_darkZone('dz-24', 450, 2000)],
      checkpoints: [
        Checkpoint(
          id: 'cp-24a',
          rect: const Rect.fromLTWH(500, 380 - 58, 34, 58),
        ),
        _checkpoint('cp-24b', 1160),
        // The warmest glow in the darkness. It is not your friend.
        Checkpoint(
          id: 'cp-24fake',
          rect: const Rect.fromLTWH(1700, 340 - 58, 34, 58),
          fake: true,
        ),
        Checkpoint(
          id: 'cp-24c',
          rect: const Rect.fromLTWH(1830, 340 - 58, 34, 58),
        ),
      ],
      goal: Goal(rect: const Rect.fromLTWH(2570, 340 - 86, 54, 86)),
      traps: [
        BreakPlatformTrap(platformId: 'br-24b', triggerX: 850, delay: 0.22),
        ChasingSpikeTrap(
          spikeId: 'chaser-24',
          triggerX: 1005,
          minX: 640,
          // Stops well short of the checkpoint at 1160 and the jump pad:
          // respawning there must never be an instant death.
          maxX: 1080,
          speed: 185,
        ),
        FakeCheckpointTrap(
          checkpointId: 'cp-24fake',
          revealSpikeIds: ['fl-24a', 'fl-24b'],
        ),
      ],
    ),
    // A four-chamber exam of callbacks — the classics, the mirrors, the
    // stacked trifecta of zones, and a goal that takes one last dive. The
    // real flag waits quietly behind you.
    Level(
      number: 25,
      title: 'The Last Laugh',
      width: 3000,
      playerStart: _start(),
      platforms: [
        _ground('g-25', 0, 2900),
        _platform('r-25a', 560, 310, 220),
        _platform('r-25b', 820, 310, 200),
      ],
      spikes: [
        // Chamber 1: the classics.
        _upSpike('slide-25', 250),
        _downSpike('drop-25', 400, 110),
        // Chamber 2: the mirror corridor and its lids.
        _downSpike('lid-25a', 600, 332),
        _downSpike('lid-25b', 680, 332),
        _downSpike('lid-25c', 730, 332),
        _downSpike('lid-25d', 860, 332),
        _downSpike('lid-25e', 940, 332),
        _upSpike('mimic-25', 990),
        // The twin arena, mirrored around x=1300.
        _upSpike('arena-25a', 1150),
        _upSpike('arena-25b', 1450),
        // Chamber 3: one spike in the heart of the trifecta.
        _upSpike('trifecta-25', 1900),
        // Under nothing: chamber 4 is honest. Almost.
      ],
      iceZones: [_iceZone('ice-25', 1750, 300)],
      reverseZones: [_reverseZone('rz-25', 1750, 300)],
      darkZones: [_darkZone('dz-25', 1700, 550)],
      checkpoints: [
        _checkpoint('cp-25a', 520),
        _checkpoint('cp-25b', 1650),
        _checkpoint('cp-25c', 2280),
      ],
      decoyGoal: Goal(rect: const Rect.fromLTWH(2700, floorY - 86, 54, 86)),
      goal: _goal(2450, visible: false),
      traps: [
        SlideSpikeTrap(
          spikeId: 'slide-25',
          triggerDistance: 100,
          moveDistance: 70,
          speed: 380,
        ),
        DropSpikeTrap(spikeId: 'drop-25', triggerX: 350),
        MimicSpikeTrap(
          spikeId: 'mimic-25',
          triggerX: 570,
          minX: 590,
          maxX: 1000,
          // Harder than level 22's 0.55, but beatable — the default 0.9
          // closed faster than the hop window under the lids allowed.
          speedFactor: 0.7,
        ),
        EvilTwinTrap(mirrorX: 1300, range: 300),
        FleeingGoalTrap(cliffX: 2900, retreatDistance: 80),
      ],
    ),
    // The first real jump is the panic button: it starts all three narrow
    // bridge platforms at once. Restraint matters again in the ice basin,
    // where a fast launch hits the roof and a gentle launch finds the exit.
    Level(
      number: 26,
      title: 'Panic Button',
      width: 2880,
      playerStart: _start(),
      platforms: [
        _ground('g-26-start', 0, 620),
        // Low enough to punish a reflex jump without making the fake-spike
        // lesson lethal. The first bridge is already visible past its edge.
        _platform('roof-26', 150, 330, 360, height: 48),
        // Deliberately narrower than the rare-coin eligibility threshold:
        // a bonus coin must never ask the player to wait on the clockwork.
        _platform('clock-26a', 650, 445, 72),
        _platform('clock-26b', 850, 365, 74),
        _platform('clock-26c', 1070, 430, 76),
        // A fixed breather island. Its flag respawns on the island itself.
        _platform('safe-island-26', 1240, 440, 300, height: 160),
        // The runway ends just before a lower pad, forcing a short fall onto
        // it. A pad embedded in continuous ground would never trigger.
        _platform('brake-runway-26', 1540, floorY, 420, height: 80),
        _ground('g-26-exit', 2032, 408),
        // Nothing is fake here: the flag is honest, but its island is not.
        _platform('honest-island-26', 2480, 440, 330, cracked: true),
      ],
      spikes: [
        // Walking through is safe. Jumping merely starts the bridge early
        // and visibly shifts its rhythm, so the lesson never soft-locks.
        _upSpike('fake-26a', 210, dangerous: false),
        _upSpike('fake-26b', 290, dangerous: false),
        _upSpike('fake-26c', 370, dangerous: false),
        _upSpike('fake-26d', 450, dangerous: false),
        _downSpike('panic-lid-26a', 210, 352),
        _downSpike('panic-lid-26b', 290, 352),
        _downSpike('panic-lid-26c', 370, 352),
        _downSpike('panic-lid-26d', 450, 352),
        // The first necessary jump, placed just beyond the low roof.
        _upSpike('start-26', 550),
        // A gentle pad launch peaks below these. Entering the pad quickly
        // selects its wild velocity and makes the same visible roof lethal.
        _downSpike('speed-lid-26a', 1960, 340),
        _downSpike('speed-lid-26b', 2020, 340),
      ],
      jumpPads: [
        JumpPad(
          id: 'brake-pad-26',
          rect: const Rect.fromLTWH(1960, 536, 72, 14),
        ),
      ],
      iceZones: [
        IceZone(
          id: 'brake-ice-26',
          rect: const Rect.fromLTWH(1540, floorY - 24, 420, 24),
        ),
      ],
      checkpoints: [
        Checkpoint(
          id: 'cp-26a',
          rect: const Rect.fromLTWH(1400, 382, 34, 58),
        ),
        _checkpoint('cp-26b', 2300),
      ],
      goal: Goal(rect: const Rect.fromLTWH(2670, 354, 54, 86)),
      traps: [
        ActivateMovingPlatformTrap(
          platformId: 'clock-26a',
          speed: 190,
          minX: 640,
          maxX: 780,
        ),
        ActivateMovingPlatformTrap(
          platformId: 'clock-26b',
          speed: -205,
          minX: 820,
          maxX: 960,
        ),
        ActivateMovingPlatformTrap(
          platformId: 'clock-26c',
          speed: 185,
          minX: 1020,
          maxX: 1160,
        ),
        DisappearPlatformTrap(platformId: 'honest-island-26', delay: 1.05),
      ],
    ),
    // One short course, remembered incorrectly. The decoy flag sends the
    // player back for a second lap: the familiar floor spike is now harmless,
    // its harmless ceiling twin is armed, and the bridge has moved downstairs.
    Level(
      number: 27,
      title: 'Déjà Troll',
      width: 2200,
      playerStart: _start(),
      platforms: [
        _ground('g-27-start', 0, 700),
        // Keeps the harmless first-lap ceiling spike visually grounded and
        // makes its second-lap danger readable rather than a floating trap.
        _platform('memory-roof-27', 330, 310, 220),
        // Round one is intentionally broad and readable.
        _platform('lap1-27a', 740, 430, 220),
        _platform('lap1-27b', 1000, 430, 220),
        // These roofs preview the low second-lap corridor. Their tops are
        // deliberately too high to become rare-coin spawn candidates.
        _platform('lap2-roof-27a', 710, 310, 270),
        _platform('lap2-roof-27b', 990, 310, 270),
        // Round two swaps in a lower, tighter stepping-stone route.
        Platform(
          id: 'lap2-27a',
          rect: const Rect.fromLTWH(730, 470, 76, 22),
          solid: false,
          visible: false,
        ),
        Platform(
          id: 'lap2-27b',
          rect: const Rect.fromLTWH(840, 445, 76, 22),
          solid: false,
          visible: false,
        ),
        Platform(
          id: 'lap2-27c',
          rect: const Rect.fromLTWH(950, 470, 76, 22),
          solid: false,
          visible: false,
        ),
        Platform(
          id: 'lap2-27d',
          rect: const Rect.fromLTWH(1060, 445, 76, 22),
          solid: false,
          visible: false,
        ),
        Platform(
          id: 'lap2-27e',
          rect: const Rect.fromLTWH(1170, 470, 76, 22),
          solid: false,
          visible: false,
        ),
        _ground('g-27-finish', 1280, 920),
      ],
      spikes: [
        // Lap one teaches: jump the floor spike; the ceiling spike is set
        // dressing. Lap two silently reverses only their dangerous flags.
        _upSpike('memory-floor-27', 420),
        Spike(
          id: 'memory-ceiling-27',
          rect: const Rect.fromLTWH(419, 332, 42, 38),
          direction: SpikeDirection.down,
          dangerous: false,
        ),
        Spike(
          id: 'lap2-lid-27a',
          rect: const Rect.fromLTWH(810, 332, 42, 38),
          direction: SpikeDirection.down,
          dangerous: false,
        ),
        Spike(
          id: 'lap2-lid-27b',
          rect: const Rect.fromLTWH(1030, 332, 42, 38),
          direction: SpikeDirection.down,
          dangerous: false,
        ),
        Spike(
          id: 'lap2-lid-27c',
          rect: const Rect.fromLTWH(1140, 332, 42, 38),
          direction: SpikeDirection.down,
          dangerous: false,
        ),
        // These remain honest and visible on both laps. The memory trick
        // changes, but the course never becomes an invisible guessing game.
        _upSpike('honest-27a', 1440),
        _upSpike('honest-27b', 1660),
      ],
      decoyGoal: _goal(2040),
      goal: _goal(2040, visible: false),
      traps: [
        SecondLapTrap(
          returnPosition: _start(),
          hidePlatformIds: ['lap1-27a', 'lap1-27b'],
          showPlatformIds: [
            'lap2-27a',
            'lap2-27b',
            'lap2-27c',
            'lap2-27d',
            'lap2-27e',
          ],
          armSpikeIds: [
            'memory-ceiling-27',
            'lap2-lid-27a',
            'lap2-lid-27b',
            'lap2-lid-27c',
          ],
          disarmSpikeIds: ['memory-floor-27'],
        ),
        DisappearPlatformTrap(platformId: 'lap2-27b', delay: 0.58),
        DisappearPlatformTrap(platformId: 'lap2-27d', delay: 0.58),
      ],
    ),
    // Two platform worlds, exactly one of them real. Every normal jump
    // flips which — pad launches don't count. The rule the level teaches:
    // aim for the ghost, because your own jump is what makes it real.
    Level(
      number: 28,
      title: "Schrödinger's Bridge",
      width: 2760,
      playerStart: _start(),
      platforms: [
        _ground('g28-start', 0, 520),
        // Demo pair over solid ground: hop around, watch the worlds flip,
        // fall through a ghost harmlessly. Nothing here can kill.
        _quantumA('qa-demo', 340, 430, 70),
        _quantumB('qb-demo', 430, 430, 70),
        // Bridge one: strict alternation. The first stone must be a ghost
        // when you jump — your jump solidifies it.
        _quantumB('b28-1', 570, 430, 110),
        _quantumA('a28-1', 730, 430, 110),
        _quantumB('b28-2', 890, 430, 110),
        _quantumA('a28-2', 1050, 430, 90),
        _ground('g28-mid1', 1150, 250),
        // Bridge two: at the fork, the solid-looking stone is the lie.
        _quantumB('b28-3', 1450, 430, 100),
        _quantumA('a28-3', 1610, 430, 100),
        _quantumB('b28-4', 1770, 430, 100),
        _quantumA('bait-28', 1785, 475, 90),
        _quantumA('a28-4', 1930, 430, 90),
        _ground('g28-mid2', 2050, 280),
        // The finale platform obeys the same rule as everything else: it
        // must be a ghost when you jump onto the pad, because that jump
        // flips it and the launch itself never will.
        _quantumA('finale-28', 2400, 340, 140),
        _platform('exit-28', 2570, 340, 190, height: 260),
      ],
      spikes: [
        // Forces the demonstration jump right next to the demo pair.
        _upSpike('intro-28', 250),
      ],
      jumpPads: [
        // Harmless rehearsal: launches high over solid ground, and the
        // worlds visibly do NOT flip mid-flight.
        JumpPad(
          id: 'demo-pad-28',
          rect: const Rect.fromLTWH(2090, floorY - 14, 72, 14),
        ),
        JumpPad(
          id: 'launch-28',
          rect: const Rect.fromLTWH(2240, floorY - 14, 72, 14),
        ),
      ],
      checkpoints: [
        // Both flags stand on neutral ground that never flips.
        _checkpoint('cp-28a', 1220),
        _checkpoint('cp-28b', 2170),
      ],
      goal: Goal(rect: const Rect.fromLTWH(2650, 340 - 86, 54, 86)),
      traps: [
        QuantumSwapTrap(
          groupA: [
            'qa-demo',
            'a28-1',
            'a28-2',
            'a28-3',
            'bait-28',
            'a28-4',
            'finale-28',
          ],
          groupB: ['qb-demo', 'b28-1', 'b28-2', 'b28-3', 'b28-4'],
        ),
      ],
    ),
    // A translucent echo replays your movement 1.2 seconds late. Harmless
    // in the entry room, lethal past the red line. The perfect run out is
    // the enemy on the way back — and it catches up whenever you stand
    // still. Checkpoints wipe its memory.
    Level(
      number: 29,
      title: 'Echo Chamber',
      width: 2320,
      playerStart: _start(),
      platforms: [
        // One continuous floor: the lower level doubles as the return
        // route, so falling from above is a detour, never a death.
        _ground('g29-floor', 0, 2260),
        _wall('turn-wall-29', 2260, 180),
        // Thin two-story architecture: the outward route runs on top.
        _platform('step-29', 430, 430, 80),
        _platform('u29-1', 540, 340, 320),
        _platform('u29-2', 930, 340, 340),
        _platform('u29-3', 1340, 340, 330),
        _platform('u29-4', 1740, 340, 220),
        _platform('trapdoor-29', 1960, 340, 150, cracked: true),
        // Low roofs force short, precise hops while the echo tails you.
        _platform('roof-29a', 600, 150, 220),
        _platform('roof-29b', 1400, 150, 220),
      ],
      spikes: [
        Spike(
          id: 'lid-29a',
          rect: const Rect.fromLTWH(640, 172, 42, 38),
          direction: SpikeDirection.down,
        ),
        Spike(
          id: 'lid-29b',
          rect: const Rect.fromLTWH(720, 172, 42, 38),
          direction: SpikeDirection.down,
        ),
        Spike(
          id: 'lid-29c',
          rect: const Rect.fromLTWH(1450, 172, 42, 38),
          direction: SpikeDirection.down,
        ),
        Spike(
          id: 'lid-29d',
          rect: const Rect.fromLTWH(1530, 172, 42, 38),
          direction: SpikeDirection.down,
        ),
        // Hopped on the way out (from above they sit under your route)...
        Spike(id: 'up-29a', rect: const Rect.fromLTWH(760, 304, 40, 36)),
        Spike(id: 'up-29b', rect: const Rect.fromLTWH(1560, 304, 40, 36)),
        // ...and these two only matter on the lower return route.
        _upSpike('floor-29a', 1100),
        _upSpike('floor-29b', 600),
      ],
      checkpoints: [
        Checkpoint(
          id: 'cp-29a',
          rect: const Rect.fromLTWH(1180, 340 - 58, 34, 58),
        ),
        _checkpoint('cp-29b', 2150),
      ],
      decoyGoal: Goal(rect: const Rect.fromLTWH(2040, 340 - 86, 54, 86)),
      // The real goal stands just PAST the red line, so the last touch
      // happens where your echo is still lethal: outrun yourself once more.
      goal: _goal(300, visible: false),
      traps: [
        EchoTrap(armX: 260),
        BreakPlatformTrap(
          platformId: 'trapdoor-29',
          triggerX: 1995,
          delay: 0.22,
        ),
        FakeGoalTrap(revealSpikeIds: []),
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

DarkZone _darkZone(String id, double x, double width) {
  // Full-height: darkness rules the whole screen while the player is inside.
  return DarkZone(id: id, rect: Rect.fromLTWH(x, 0, width, worldHeight));
}

/// Quantum world A (blue): starts solid; every jump may ghost it.
Platform _quantumA(String id, double x, double y, double width) {
  return Platform(
    id: id,
    rect: Rect.fromLTWH(x, y, width, 22),
    color: const Color(0xFF1D4ED8),
  );
}

/// Quantum world B (violet): starts as a ghost; a jump makes it real.
Platform _quantumB(String id, double x, double y, double width) {
  return Platform(
    id: id,
    rect: Rect.fromLTWH(x, y, width, 22),
    color: const Color(0xFF7C3AED),
    solid: false,
    ghost: true,
  );
}

Platform _wall(String id, double x, double height, {bool solid = true}) {
  return Platform(
    id: id,
    rect: Rect.fromLTWH(x, floorY - height, 26, height),
    color: const Color(0xFF37474F),
    solid: solid,
  );
}
