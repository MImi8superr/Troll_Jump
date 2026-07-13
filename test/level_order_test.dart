import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:troll_dash/game/level_progress.dart';
import 'package:troll_dash/game/levels.dart';

void main() {
  test('new level order has ten inserted levels and sequential numbers', () {
    final levels = buildLevels();

    expect(levels, hasLength(39));
    expect(levels.map((level) => level.number), List.generate(39, (i) => i + 1));
    expect(levels.where((level) => _newLevelTitles.contains(level.title)), hasLength(10));
    expect(levels.last.title, 'Echo Chamber');
  });

  test('legacy numeric progress migrates across inserted levels', () async {
    SharedPreferences.setMockInitialValues({'highest_unlocked_level': 29});
    LevelProgress.highestUnlockedLevel.value = 1;

    await LevelProgress.load();

    expect(LevelProgress.highestUnlockedLevel.value, 39);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('highest_unlocked_level'), 39);
    expect(prefs.getBool('level_order_39_migrated'), isTrue);
  });
}

const _newLevelTitles = {
  'Wobbly Welcome',
  'Coin Breadcrumbs',
  'Polite Timing',
  'No, Back There',
  'Ceiling Sigh',
  'Three Bad Ideas',
  'Fake Promotion',
  'Bounce Contract',
  'Switcheroo',
  'Echo Detour',
};
