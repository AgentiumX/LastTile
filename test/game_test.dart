import 'package:flutter_test/flutter_test.dart';

import 'package:last_tile/engine/game_engine.dart';
import 'package:last_tile/engine/path_solver.dart';
import 'package:last_tile/models/game_state.dart';
import 'package:last_tile/models/level.dart';
import 'package:last_tile/models/level_data.dart';
import 'package:last_tile/models/tile.dart';
import 'package:last_tile/core/utils/direction.dart';

void main() {
  group('PathSolver', () {
    test('solves simple 8x8 level', () {
      final level = Level(
        id: 'test_1',
        rows: 8,
        cols: 8,
        optimalSteps: 0,
        allowedSteps: 0,
        specialTiles: [
          Tile(row: 0, col: 0, type: TileType.start),
          Tile(row: 7, col: 7, type: TileType.end),
        ],
      );
      final result = PathSolver.findOptimalSteps(level);
      expect(result, isNotNull);
      expect(result, equals(14));
    });

    test('solves level with teleport', () {
      final level = Level(
        id: 'test_tp',
        rows: 8,
        cols: 8,
        optimalSteps: 0,
        allowedSteps: 0,
        specialTiles: [
          Tile(row: 0, col: 0, type: TileType.start),
          Tile(row: 7, col: 7, type: TileType.end),
          Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'a'),
          Tile(row: 6, col: 6, type: TileType.teleport, teleportId: 'a'),
        ],
      );
      final result = PathSolver.findOptimalSteps(level);
      expect(result, isNotNull);
      expect(result!, lessThan(14));
    });

    test('solves level with key and lock', () {
      final level = Level(
        id: 'test_kl',
        rows: 8,
        cols: 8,
        optimalSteps: 0,
        allowedSteps: 0,
        specialTiles: [
          Tile(row: 0, col: 0, type: TileType.start),
          Tile(row: 7, col: 7, type: TileType.end),
          Tile(row: 2, col: 3, type: TileType.key),
          Tile(row: 5, col: 4, type: TileType.lock),
        ],
      );
      final result = PathSolver.findOptimalSteps(level);
      expect(result, isNotNull);
    });

    test('hasSolution returns true for solvable level', () {
      final level = Level(
        id: 'test_solvable',
        rows: 8,
        cols: 8,
        optimalSteps: 0,
        allowedSteps: 0,
        specialTiles: [
          Tile(row: 0, col: 0, type: TileType.start),
          Tile(row: 7, col: 7, type: TileType.end),
        ],
      );
      expect(PathSolver.hasSolution(level), isTrue);
    });
  });

  group('GameEngine', () {
    late Level testLevel;
    late GameState initialState;

    setUp(() {
      testLevel = Level(
        id: 'test_engine',
        rows: 8,
        cols: 8,
        optimalSteps: 14,
        allowedSteps: 18,
        specialTiles: [
          Tile(row: 0, col: 0, type: TileType.start),
          Tile(row: 7, col: 7, type: TileType.end),
        ],
      );
      initialState = GameState.initial(testLevel);
    });

    test('initial state is playing', () {
      expect(initialState.status, equals(GameStatus.playing));
      expect(initialState.remainingSteps, equals(18));
      expect(initialState.player.row, equals(0));
      expect(initialState.player.col, equals(0));
    });

    test('move changes player position', () {
      final engine = GameEngine();
      final newState = engine.move(initialState, Direction.right);
      expect(newState.player.col, equals(1));
      expect(newState.currentSteps, equals(1));
      expect(newState.remainingSteps, equals(17));
    });

    test('visited tile cannot be re-entered', () {
      final engine = GameEngine();
      final right = engine.move(initialState, Direction.right);
      final left = engine.move(right, Direction.left);
      expect(left.player.col, equals(1));
    });

    test('out of bounds move is ignored', () {
      final engine = GameEngine();
      final up = engine.move(initialState, Direction.up);
      expect(up.player.row, equals(0));
      expect(up.currentSteps, equals(0));
    });

    test('steps running out causes failure', () {
      final engine = GameEngine();
      var state = initialState;
      for (int i = 0; i < 18; i++) {
        if (state.status != GameStatus.playing) break;
        state = engine.move(state, Direction.right);
        if (state.player.col >= 7) {
          for (int j = 0; j < 10 && state.status == GameStatus.playing; j++) {
            state = engine.move(state, Direction.down);
          }
        }
      }
      if (state.status == GameStatus.failed) {
        expect(state.lastFeedback, isNotNull);
      }
    });

    test('calculateStars returns correct values', () {
      final engine = GameEngine();
      expect(engine.calculateStars(14, 14), equals(5));
      expect(engine.calculateStars(15, 14), equals(4));
      expect(engine.calculateStars(16, 14), equals(3));
      expect(engine.calculateStars(17, 14), equals(2));
      expect(engine.calculateStars(18, 14), equals(1));
    });

    test('reaching end tile completes the game', () {
      final smallLevel = Level(
        id: 'test_win',
        rows: 3,
        cols: 3,
        optimalSteps: 4,
        allowedSteps: 10,
        specialTiles: [
          Tile(row: 0, col: 0, type: TileType.start),
          Tile(row: 2, col: 2, type: TileType.end),
        ],
      );
      final engine = GameEngine();
      var state = GameState.initial(smallLevel);
      state = engine.move(state, Direction.down);
      state = engine.move(state, Direction.down);
      state = engine.move(state, Direction.right);
      state = engine.move(state, Direction.right);
      expect(state.status, equals(GameStatus.completed));
    });

    test('key and lock mechanics work', () {
      final keyLockLevel = Level(
        id: 'test_keylock',
        rows: 5,
        cols: 5,
        optimalSteps: 0,
        allowedSteps: 20,
        specialTiles: [
          Tile(row: 0, col: 0, type: TileType.start),
          Tile(row: 4, col: 4, type: TileType.end),
          Tile(row: 2, col: 2, type: TileType.key),
          Tile(row: 3, col: 3, type: TileType.lock),
        ],
      );
      final engine = GameEngine();
      var state = GameState.initial(keyLockLevel);
      expect(state.player.keys, equals(0));

      state = engine.move(state, Direction.down);
      state = engine.move(state, Direction.down);
      state = engine.move(state, Direction.right);
      state = engine.move(state, Direction.right);
      expect(state.player.keys, equals(1));

      state = engine.move(state, Direction.down);
      state = engine.move(state, Direction.right);
      expect(state.player.keys, equals(0));
    });

    test('teleport mechanics work', () {
      final tpLevel = Level(
        id: 'test_tp',
        rows: 8,
        cols: 8,
        optimalSteps: 0,
        allowedSteps: 20,
        specialTiles: [
          Tile(row: 0, col: 0, type: TileType.start),
          Tile(row: 7, col: 7, type: TileType.end),
          Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 't1'),
          Tile(row: 6, col: 6, type: TileType.teleport, teleportId: 't1'),
        ],
      );
      final engine = GameEngine();
      var state = GameState.initial(tpLevel);
      state = engine.move(state, Direction.down);
      state = engine.move(state, Direction.right);
      expect(state.player.row, equals(6));
      expect(state.player.col, equals(6));
    });
  });

  group('LevelData', () {
    test('all levels are solvable', () {
      final levels = LevelData.getAllLevels();
      expect(levels.length, greaterThanOrEqualTo(50));
      for (final level in levels) {
        expect(PathSolver.hasSolution(level), isTrue,
            reason: 'Level ${level.id} has no solution');
      }
    });

    test('allowedSteps >= optimalSteps', () {
      final levels = LevelData.getAllLevels();
      for (final level in levels) {
        expect(level.allowedSteps, greaterThanOrEqualTo(level.optimalSteps),
            reason: 'Level ${level.id}: allowedSteps < optimalSteps');
      }
    });
  });
}
