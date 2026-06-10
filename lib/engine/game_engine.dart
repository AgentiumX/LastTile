import '../core/utils/direction.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../models/tile.dart';
import 'path_solver.dart';

class GameEngine {
  GameState move(GameState state, Direction direction) {
    if (state.status != GameStatus.playing) return state;

    final newRow = state.player.row + direction.dy;
    final newCol = state.player.col + direction.dx;

    if (!state.isInBounds(newRow, newCol)) return state;

    final targetTile = state.getTile(newRow, newCol);
    final tileKey = state.tileKey(newRow, newCol);

    if (state.isVisited(newRow, newCol) &&
        !(targetTile?.type == TileType.teleport)) {
      return state;
    }

    if (targetTile != null && targetTile.type == TileType.lock) {
      if (state.player.keys <= 0) {
        return state;
      }
    }

    GameState newState = state.copyWith(
      player: state.player.copyWith(row: newRow, col: newCol),
      remainingSteps: state.remainingSteps - 1,
      currentSteps: state.currentSteps + 1,
    );

    newState.visitedMap[tileKey] = true;

    int newKeys = state.player.keys;
    if (targetTile != null && targetTile.type == TileType.lock) {
      newKeys -= 1;
    }
    if (targetTile != null && targetTile.type == TileType.key) {
      newKeys += 1;
    }
    if (newKeys != state.player.keys) {
      newState = newState.copyWith(
        player: newState.player.copyWith(keys: newKeys),
      );
    }

    if (targetTile != null &&
        targetTile.type == TileType.teleport &&
        targetTile.teleportId != null) {
      final pair = _findTeleportPair(
        state.level,
        targetTile.teleportId!,
        (targetTile.row, targetTile.col),
      );
      if (pair != null) {
        newState = newState.copyWith(
          player: newState.player.copyWith(row: pair.$1, col: pair.$2),
        );
        newState.visitedMap[newState.tileKey(pair.$1, pair.$2)] = true;
      }
    }

    final endTile = state.level.endTile;
    if (endTile != null &&
        newState.player.row == endTile.row &&
        newState.player.col == endTile.col) {
      final dist = PathSolver.remainingDistanceEstimate(
        state.level,
        newState.player.row,
        newState.player.col,
      );
      return newState.copyWith(
        status: GameStatus.completed,
        distanceToEnd: dist,
        lastFeedback: '关卡完成！步数: ${newState.currentSteps}',
      );
    }

    if (newState.remainingSteps <= 0) {
      final dist = PathSolver.remainingDistanceEstimate(
        state.level,
        newState.player.row,
        newState.player.col,
      );
      return newState.copyWith(
        status: GameStatus.failed,
        distanceToEnd: dist,
        lastFeedback: '距离终点：剩余${dist}格',
      );
    }

    if (_isTrapped(newState)) {
      final dist = PathSolver.remainingDistanceEstimate(
        state.level,
        newState.player.row,
        newState.player.col,
      );
      return newState.copyWith(
        status: GameStatus.failed,
        distanceToEnd: dist,
        lastFeedback: '无路可走！距离终点：剩余${dist}格',
      );
    }

    return newState;
  }

  (int, int)? _findTeleportPair(
    Level level,
    String teleportId,
    (int, int) currentPos,
  ) {
    for (final t in level.specialTiles) {
      if (t.type == TileType.teleport &&
          t.teleportId == teleportId &&
          (t.row, t.col) != currentPos) {
        return (t.row, t.col);
      }
    }
    return null;
  }

  bool _isTrapped(GameState state) {
    final directions = [
      Direction.up,
      Direction.down,
      Direction.left,
      Direction.right,
    ];

    for (final dir in directions) {
      final nr = state.player.row + dir.dy;
      final nc = state.player.col + dir.dx;
      if (!state.isInBounds(nr, nc)) continue;

      final tile = state.getTile(nr, nc);
      if (tile != null && tile.type == TileType.lock && state.player.keys <= 0) {
        continue;
      }
      if (!state.isVisited(nr, nc)) return false;
    }
    return true;
  }

  int calculateStars(int currentSteps, int optimalSteps) {
    final delta = currentSteps - optimalSteps;
    if (delta <= 0) return 5;
    if (delta == 1) return 4;
    if (delta == 2) return 3;
    if (delta == 3) return 2;
    return 1;
  }
}
