import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/direction.dart';
import '../engine/game_engine.dart';
import '../engine/level_loader.dart';
import '../engine/path_solver.dart';
import '../models/game_state.dart';
import '../storage/save_manager.dart';

class GameNotifier extends StateNotifier<GameState?> {
  final GameEngine _engine = GameEngine();
  int _currentLevelIndex = 0;

  GameNotifier() : super(null);

  int get currentLevelIndex => _currentLevelIndex;

  Future<void> loadLevel(int index) async {
    _currentLevelIndex = index;
    final level = LevelLoader.loadSync(index);
    state = GameState.initial(level);
  }

  void move(Direction direction) {
    if (state == null) return;
    state = _engine.move(state!, direction);

    if (state?.status == GameStatus.completed) {
      _saveCompletion();
    }
  }

  void restart() {
    if (state == null) return;
    state = GameState.initial(state!.level);
  }

  int? get bestSteps {
    if (state == null) return null;
    return SaveManager.bestSteps(state!.level.id);
  }

  int calculateStars() {
    if (state == null) return 0;
    return _engine.calculateStars(
      state!.currentSteps,
      state!.level.optimalSteps,
    );
  }

  void _saveCompletion() {
    if (state == null) return;
    final levelId = state!.level.id;
    final currentSteps = state!.currentSteps;
    SaveManager.setBestSteps(levelId, currentSteps);

    final stars = _engine.calculateStars(
      currentSteps,
      state!.level.optimalSteps,
    );
    SaveManager.setStars(levelId, stars);

    final next = _currentLevelIndex + 1;
    if (next > SaveManager.unlockedLevel && next < LevelLoader.totalLevels) {
      SaveManager.unlockedLevel = next;
    }
  }

  int get remainingDistance {
    if (state == null) return 0;
    return PathSolver.remainingDistanceEstimate(
      state!.level,
      state!.player.row,
      state!.player.col,
    );
  }
}

final gameProvider =
    StateNotifierProvider<GameNotifier, GameState?>((ref) => GameNotifier());

final totalLevelsProvider = Provider<int>((ref) => LevelLoader.totalLevels);

final unlockedLevelProvider = Provider<int>((ref) {
  return SaveManager.unlockedLevel;
});

class LevelScore {
  final int? bestSteps;
  final int? stars;
  LevelScore({this.bestSteps, this.stars});
}

final levelScoreProvider = Provider.family<LevelScore, int>((ref, index) {
  final level = LevelLoader.loadSync(index);
  return LevelScore(
    bestSteps: SaveManager.bestSteps(level.id),
    stars: SaveManager.stars(level.id),
  );
});
