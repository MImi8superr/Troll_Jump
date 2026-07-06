import 'package:flutter/foundation.dart';

class LevelProgress {
  LevelProgress._();

  static final ValueNotifier<int> highestUnlockedLevel = ValueNotifier<int>(1);

  static bool isUnlocked(int levelNumber) {
    return levelNumber <= highestUnlockedLevel.value;
  }

  static void unlockThrough(int levelNumber) {
    if (levelNumber <= highestUnlockedLevel.value) {
      return;
    }
    highestUnlockedLevel.value = levelNumber;
  }
}
