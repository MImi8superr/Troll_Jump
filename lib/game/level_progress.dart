import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks how far the player has unlocked and persists it across launches.
///
/// The highest unlocked level is exposed as a [ValueNotifier] so the level
/// select screen can rebuild reactively. Progress is written to
/// [SharedPreferences] whenever it advances, and restored on startup via
/// [load]. Writes are fire-and-forget so gameplay never blocks on disk I/O.
class LevelProgress {
  LevelProgress._();

  static const String _storageKey = 'highest_unlocked_level';
  static const String _migrationKey = 'level_order_39_migrated';

  static final ValueNotifier<int> highestUnlockedLevel = ValueNotifier<int>(1);

  /// Restores saved progress. Safe to call before [runApp]; failures (e.g. a
  /// missing platform plugin in tests) are swallowed so the app still starts.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getInt(_storageKey);
      if (stored != null) {
        final migrated = prefs.getBool(_migrationKey) == true
            ? stored
            : _migrateLegacyHighestUnlocked(stored);
        if (migrated > highestUnlockedLevel.value) {
          highestUnlockedLevel.value = migrated;
        }
        if (migrated != stored || prefs.getBool(_migrationKey) != true) {
          await prefs.setInt(_storageKey, migrated);
          await prefs.setBool(_migrationKey, true);
        }
      } else {
        await prefs.setBool(_migrationKey, true);
      }
    } catch (_) {
      // Keep the default (level 1) if storage is unavailable.
    }
  }

  static bool isUnlocked(int levelNumber) {
    return levelNumber <= highestUnlockedLevel.value;
  }

  static void unlockThrough(int levelNumber) {
    if (levelNumber <= highestUnlockedLevel.value) {
      return;
    }
    highestUnlockedLevel.value = levelNumber;
    _persist(levelNumber);
  }

  static int _migrateLegacyHighestUnlocked(int legacyLevelNumber) {
    if (legacyLevelNumber <= 0) {
      return 1;
    }
    const insertedBeforeLegacyLevels = [4, 7, 10, 13, 16, 19, 22, 25, 27, 29];
    final insertedUnlocked = insertedBeforeLegacyLevels
        .where((legacyInsertionPoint) => legacyLevelNumber >= legacyInsertionPoint)
        .length;
    return legacyLevelNumber + insertedUnlocked;
  }

  static Future<void> _persist(int levelNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, levelNumber);
      await prefs.setBool(_migrationKey, true);
    } catch (_) {
      // Non-fatal: progress simply won't survive this session.
    }
  }
}
