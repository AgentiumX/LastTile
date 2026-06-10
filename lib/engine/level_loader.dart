import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/level.dart';
import '../models/level_data.dart';

class LevelLoader {
  static Future<Level> loadFromAssets(int levelIndex) async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/levels/level_${levelIndex + 1}.json',
      );
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Level.fromJson(json);
    } catch (_) {
      return LevelData.getLevel(levelIndex);
    }
  }

  static Level loadSync(int levelIndex) {
    return LevelData.getLevel(levelIndex);
  }

  static int get totalLevels => LevelData.totalLevels;
}
