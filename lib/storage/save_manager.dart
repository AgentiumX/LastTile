import 'package:hive_flutter/hive_flutter.dart';

class SaveManager {
  static const String boxName = 'last_tile_save';
  static const String keyUnlocked = 'unlockedLevel';
  static const String keyBestStepsPrefix = 'best_';
  static const String keyStarsPrefix = 'stars_';

  static Box<dynamic>? _box;

  static Future<void> init() async {
    _box ??= await Hive.openBox<dynamic>(boxName);
  }

  static int get unlockedLevel {
    return (_box?.get(keyUnlocked, defaultValue: 0) as int?) ?? 0;
  }

  static set unlockedLevel(int value) {
    _box?.put(keyUnlocked, value);
  }

  static int? bestSteps(String levelId) {
    return _box?.get('$keyBestStepsPrefix$levelId') as int?;
  }

  static void setBestSteps(String levelId, int steps) {
    final current = bestSteps(levelId);
    if (current == null || steps < current) {
      _box?.put('$keyBestStepsPrefix$levelId', steps);
    }
  }

  static int? stars(String levelId) {
    return _box?.get('$keyStarsPrefix$levelId') as int?;
  }

  static void setStars(String levelId, int stars) {
    final current = this.stars(levelId) ?? 0;
    if (stars > current) {
      _box?.put('$keyStarsPrefix$levelId', stars);
    }
  }

  static Future<void> reset() async {
    await _box?.clear();
  }
}
