import '../models/level.dart';
import '../models/tile.dart';
import '../engine/path_solver.dart';

class LevelData {
  static final Map<int, _LevelDef> _levels = _buildAllLevels();

  static int get totalLevels => _levels.length;

  static Level getLevel(int index) {
    final def = _levels[index];
    if (def == null) {
      throw RangeError.index(index, _levels, 'level index');
    }
    return def.build(index);
  }

  static List<Level> getAllLevels() {
    final list = <Level>[];
    for (int i = 0; i < _levels.length; i++) {
      list.add(getLevel(i));
    }
    return list;
  }
}

class _LevelDef {
  final int rows;
  final int cols;
  final int startRow;
  final int startCol;
  final int endRow;
  final int endCol;
  final int bufferSteps;
  final List<Tile> specialTiles;

  _LevelDef({
    this.rows = 8,
    this.cols = 8,
    required this.startRow,
    required this.startCol,
    required this.endRow,
    required this.endCol,
    required this.bufferSteps,
    this.specialTiles = const [],
  });

  Level build(int index) {
    final tiles = <Tile>[
      Tile(row: startRow, col: startCol, type: TileType.start),
      Tile(row: endRow, col: endCol, type: TileType.end),
      ...specialTiles,
    ];

    final temp = Level(
      id: 'level_${index + 1}',
      rows: rows,
      cols: cols,
      optimalSteps: 0,
      allowedSteps: 0,
      specialTiles: tiles,
    );

    final optimal = PathSolver.findOptimalSteps(temp) ??
        ((endRow - startRow).abs() + (endCol - startCol).abs());

    return Level(
      id: 'level_${index + 1}',
      rows: rows,
      cols: cols,
      optimalSteps: optimal,
      allowedSteps: optimal + bufferSteps,
      specialTiles: tiles,
    );
  }
}

Map<int, _LevelDef> _buildAllLevels() {
  final map = <int, _LevelDef>{};
  int idx = 0;

  // === 第1-3关: 3x3/3x4 教学 ===

  // Level 1: 一面墙挡住直路 (3x3)
  map[idx++] = _LevelDef(
    rows: 3, cols: 3,
    startRow: 0, startCol: 0,
    endRow: 2, endCol: 2,
    bufferSteps: 5,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
    ],
  );

  // Level 2: 两面墙 (3x3)
  map[idx++] = _LevelDef(
    rows: 3, cols: 3,
    startRow: 0, startCol: 2,
    endRow: 2, endCol: 0,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 0, col: 1, type: TileType.wall),
      Tile(row: 2, col: 1, type: TileType.wall),
    ],
  );

  // Level 3: 横向绕墙 (3x4)
  map[idx++] = _LevelDef(
    rows: 3, cols: 4,
    startRow: 1, startCol: 0,
    endRow: 1, endCol: 3,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
    ],
  );

  // === 第4-6关: 4x4 ===

  // Level 4: 中间一列墙
  map[idx++] = _LevelDef(
    rows: 4, cols: 4,
    startRow: 0, startCol: 0,
    endRow: 3, endCol: 3,
    bufferSteps: 5,
    specialTiles: [
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
    ],
  );

  // Level 5: L形墙
  map[idx++] = _LevelDef(
    rows: 4, cols: 4,
    startRow: 0, startCol: 3,
    endRow: 3, endCol: 0,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 1, type: TileType.wall),
    ],
  );

  // Level 6: 墙+钥匙锁
  map[idx++] = _LevelDef(
    rows: 4, cols: 4,
    startRow: 0, startCol: 0,
    endRow: 3, endCol: 3,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 0, col: 2, type: TileType.key),
      Tile(row: 2, col: 3, type: TileType.lock),
    ],
  );

  // === 第7-10关: 5x5 ===

  // Level 7: 十字墙
  map[idx++] = _LevelDef(
    rows: 5, cols: 5,
    startRow: 0, startCol: 0,
    endRow: 4, endCol: 4,
    bufferSteps: 5,
    specialTiles: [
      Tile(row: 2, col: 1, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
    ],
  );

  // Level 8: 走廊
  map[idx++] = _LevelDef(
    rows: 5, cols: 5,
    startRow: 0, startCol: 0,
    endRow: 4, endCol: 4,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.wall),
    ],
  );

  // Level 9: 墙+传送
  map[idx++] = _LevelDef(
    rows: 5, cols: 5,
    startRow: 0, startCol: 4,
    endRow: 4, endCol: 0,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
      Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'a'),
      Tile(row: 3, col: 3, type: TileType.teleport, teleportId: 'a'),
    ],
  );

  // Level 10: 墙+钥匙锁
  map[idx++] = _LevelDef(
    rows: 5, cols: 5,
    startRow: 0, startCol: 0,
    endRow: 4, endCol: 4,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
      Tile(row: 1, col: 1, type: TileType.key),
      Tile(row: 3, col: 3, type: TileType.lock),
    ],
  );

  // === 第11-20关: 6x6 ===

  // Level 11
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 0, startCol: 0,
    endRow: 5, endCol: 5,
    bufferSteps: 5,
    specialTiles: [
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
      Tile(row: 2, col: 4, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 4, col: 4, type: TileType.wall),
    ],
  );

  // Level 12
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 0, startCol: 5,
    endRow: 5, endCol: 0,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
    ],
  );

  // Level 13
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 5, startCol: 0,
    endRow: 0, endCol: 5,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 4, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 4, col: 1, type: TileType.wall),
      Tile(row: 4, col: 2, type: TileType.wall),
    ],
  );

  // Level 14
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 0, startCol: 2,
    endRow: 5, endCol: 3,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 0, type: TileType.wall),
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 2, col: 4, type: TileType.wall),
      Tile(row: 4, col: 2, type: TileType.wall),
      Tile(row: 4, col: 3, type: TileType.wall),
    ],
  );

  // Level 15
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 2, startCol: 0,
    endRow: 3, endCol: 5,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 0, col: 2, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 4, col: 3, type: TileType.wall),
      Tile(row: 5, col: 3, type: TileType.wall),
      Tile(row: 2, col: 4, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
    ],
  );

  // Level 16: 墙+钥匙锁
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 0, startCol: 0,
    endRow: 5, endCol: 5,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 4, col: 4, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.key),
      Tile(row: 4, col: 1, type: TileType.lock),
    ],
  );

  // Level 17: 墙+钥匙锁
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 0, startCol: 5,
    endRow: 5, endCol: 0,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 2, col: 1, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 1, col: 3, type: TileType.key),
      Tile(row: 4, col: 2, type: TileType.lock),
    ],
  );

  // Level 18: 墙+传送
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 0, startCol: 0,
    endRow: 5, endCol: 5,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 2, col: 0, type: TileType.wall),
      Tile(row: 2, col: 1, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'b'),
      Tile(row: 4, col: 4, type: TileType.teleport, teleportId: 'b'),
    ],
  );

  // Level 19: 墙+传送+钥匙锁
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 5, startCol: 5,
    endRow: 0, endCol: 0,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.teleport, teleportId: 'c'),
      Tile(row: 4, col: 4, type: TileType.teleport, teleportId: 'c'),
      Tile(row: 1, col: 4, type: TileType.key),
      Tile(row: 4, col: 0, type: TileType.lock),
    ],
  );

  // Level 20: 双钥匙锁
  map[idx++] = _LevelDef(
    rows: 6, cols: 6,
    startRow: 0, startCol: 0,
    endRow: 5, endCol: 5,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
      Tile(row: 4, col: 1, type: TileType.wall),
      Tile(row: 0, col: 4, type: TileType.key),
      Tile(row: 3, col: 4, type: TileType.lock),
      Tile(row: 2, col: 0, type: TileType.key),
      Tile(row: 5, col: 3, type: TileType.lock),
    ],
  );

  // === 第21-35关: 7x7 ===

  // Level 21: 蛇形走廊
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 0,
    endRow: 6, endCol: 6,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 0, type: TileType.wall),
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 3, col: 5, type: TileType.wall),
      Tile(row: 3, col: 6, type: TileType.wall),
      Tile(row: 5, col: 0, type: TileType.wall),
      Tile(row: 5, col: 1, type: TileType.wall),
      Tile(row: 5, col: 2, type: TileType.wall),
      Tile(row: 5, col: 3, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
    ],
  );

  // Level 22
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 6,
    endRow: 6, endCol: 0,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.wall),
      Tile(row: 2, col: 4, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 4, col: 2, type: TileType.wall),
      Tile(row: 4, col: 3, type: TileType.wall),
      Tile(row: 4, col: 4, type: TileType.wall),
      Tile(row: 5, col: 2, type: TileType.wall),
    ],
  );

  // Level 23: 中间竖墙+横墙
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 6, startCol: 0,
    endRow: 0, endCol: 6,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 0, col: 3, type: TileType.wall),
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 4, col: 3, type: TileType.wall),
      Tile(row: 5, col: 3, type: TileType.wall),
      Tile(row: 6, col: 3, type: TileType.wall),
      Tile(row: 3, col: 0, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
    ],
  );

  // Level 24: 岛屿式墙壁
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 3,
    endRow: 6, endCol: 3,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 3, col: 5, type: TileType.wall),
      Tile(row: 5, col: 1, type: TileType.wall),
      Tile(row: 5, col: 2, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
    ],
  );

  // Level 25: 双竖墙
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 3, startCol: 0,
    endRow: 3, endCol: 6,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 0, col: 2, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 4, col: 4, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 6, col: 4, type: TileType.wall),
      Tile(row: 0, col: 5, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.wall),
      Tile(row: 5, col: 1, type: TileType.wall),
      Tile(row: 6, col: 1, type: TileType.wall),
    ],
  );

  // Level 26: 墙+钥匙锁
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 0,
    endRow: 6, endCol: 6,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 4, col: 4, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.wall),
      Tile(row: 2, col: 5, type: TileType.wall),
      Tile(row: 0, col: 4, type: TileType.key),
      Tile(row: 4, col: 3, type: TileType.lock),
    ],
  );

  // Level 27: 墙+传送
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 6,
    endRow: 6, endCol: 0,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 2, col: 1, type: TileType.wall),
      Tile(row: 4, col: 5, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.teleport, teleportId: 'd'),
      Tile(row: 4, col: 2, type: TileType.teleport, teleportId: 'd'),
    ],
  );

  // Level 28: 墙+传送+钥匙锁
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 0,
    endRow: 6, endCol: 6,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 2, col: 1, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 4, col: 3, type: TileType.wall),
      Tile(row: 4, col: 4, type: TileType.wall),
      Tile(row: 4, col: 5, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.teleport, teleportId: 'e'),
      Tile(row: 5, col: 1, type: TileType.teleport, teleportId: 'e'),
      Tile(row: 3, col: 5, type: TileType.key),
      Tile(row: 4, col: 0, type: TileType.lock),
    ],
  );

  // Level 29: 墙+钥匙锁+传送
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 6, startCol: 6,
    endRow: 0, endCol: 0,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 4, col: 3, type: TileType.wall),
      Tile(row: 5, col: 3, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.key),
      Tile(row: 5, col: 1, type: TileType.lock),
      Tile(row: 3, col: 4, type: TileType.teleport, teleportId: 'f'),
      Tile(row: 3, col: 2, type: TileType.teleport, teleportId: 'f'),
    ],
  );

  // Level 30: 双钥匙锁
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 0,
    endRow: 6, endCol: 6,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 4, col: 4, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 0, col: 5, type: TileType.key),
      Tile(row: 3, col: 5, type: TileType.lock),
      Tile(row: 3, col: 0, type: TileType.key),
      Tile(row: 6, col: 2, type: TileType.lock),
    ],
  );

  // Level 31: 墙+传送
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 0,
    endRow: 6, endCol: 6,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.wall),
      Tile(row: 5, col: 1, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.teleport, teleportId: 'g'),
      Tile(row: 4, col: 4, type: TileType.teleport, teleportId: 'g'),
    ],
  );

  // Level 32: 墙+传送
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 6,
    endRow: 6, endCol: 0,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 0, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 4, col: 3, type: TileType.wall),
      Tile(row: 6, col: 3, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.teleport, teleportId: 'h'),
      Tile(row: 5, col: 2, type: TileType.teleport, teleportId: 'h'),
    ],
  );

  // Level 33: 墙+钥匙锁+传送
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 3, startCol: 0,
    endRow: 3, endCol: 6,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 0, col: 2, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 6, col: 4, type: TileType.wall),
      Tile(row: 2, col: 4, type: TileType.key),
      Tile(row: 4, col: 2, type: TileType.lock),
      Tile(row: 0, col: 5, type: TileType.teleport, teleportId: 'i'),
      Tile(row: 6, col: 1, type: TileType.teleport, teleportId: 'i'),
    ],
  );

  // Level 34: 双传送
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 0,
    endRow: 6, endCol: 6,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 4, col: 3, type: TileType.wall),
      Tile(row: 5, col: 3, type: TileType.wall),
      Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'j1'),
      Tile(row: 5, col: 5, type: TileType.teleport, teleportId: 'j1'),
      Tile(row: 1, col: 5, type: TileType.teleport, teleportId: 'j2'),
      Tile(row: 5, col: 1, type: TileType.teleport, teleportId: 'j2'),
    ],
  );

  // Level 35: 墙+钥匙锁+传送
  map[idx++] = _LevelDef(
    rows: 7, cols: 7,
    startRow: 0, startCol: 3,
    endRow: 6, endCol: 3,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 0, type: TileType.wall),
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.wall),
      Tile(row: 1, col: 6, type: TileType.wall),
      Tile(row: 5, col: 0, type: TileType.wall),
      Tile(row: 5, col: 1, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
      Tile(row: 5, col: 6, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.key),
      Tile(row: 3, col: 5, type: TileType.lock),
      Tile(row: 2, col: 3, type: TileType.teleport, teleportId: 'k'),
      Tile(row: 4, col: 3, type: TileType.teleport, teleportId: 'k'),
    ],
  );

  // === 第36-50关: 8x8 ===

  // Level 36: 蛇形
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 0,
    endRow: 7, endCol: 7,
    bufferSteps: 4,
    specialTiles: [
      Tile(row: 1, col: 0, type: TileType.wall),
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 3, col: 5, type: TileType.wall),
      Tile(row: 3, col: 6, type: TileType.wall),
      Tile(row: 3, col: 7, type: TileType.wall),
      Tile(row: 5, col: 0, type: TileType.wall),
      Tile(row: 5, col: 1, type: TileType.wall),
      Tile(row: 5, col: 2, type: TileType.wall),
      Tile(row: 5, col: 3, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
    ],
  );

  // Level 37
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 7,
    endRow: 7, endCol: 0,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.wall),
      Tile(row: 2, col: 4, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 4, col: 2, type: TileType.wall),
      Tile(row: 4, col: 3, type: TileType.wall),
      Tile(row: 4, col: 4, type: TileType.wall),
      Tile(row: 5, col: 2, type: TileType.wall),
      Tile(row: 6, col: 2, type: TileType.wall),
      Tile(row: 6, col: 3, type: TileType.wall),
    ],
  );

  // Level 38
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 7, startCol: 0,
    endRow: 0, endCol: 7,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 0, col: 3, type: TileType.wall),
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 6, col: 4, type: TileType.wall),
      Tile(row: 7, col: 4, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
      Tile(row: 4, col: 6, type: TileType.wall),
    ],
  );

  // Level 39: 岛屿式
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 3,
    endRow: 7, endCol: 4,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.wall),
      Tile(row: 1, col: 6, type: TileType.wall),
      Tile(row: 3, col: 1, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
      Tile(row: 3, col: 5, type: TileType.wall),
      Tile(row: 3, col: 6, type: TileType.wall),
      Tile(row: 5, col: 1, type: TileType.wall),
      Tile(row: 5, col: 2, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
      Tile(row: 5, col: 6, type: TileType.wall),
    ],
  );

  // Level 40
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 3, startCol: 0,
    endRow: 4, endCol: 7,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 0, col: 2, type: TileType.wall),
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
      Tile(row: 6, col: 5, type: TileType.wall),
      Tile(row: 7, col: 5, type: TileType.wall),
      Tile(row: 0, col: 6, type: TileType.wall),
      Tile(row: 1, col: 6, type: TileType.wall),
      Tile(row: 6, col: 1, type: TileType.wall),
      Tile(row: 7, col: 1, type: TileType.wall),
    ],
  );

  // Level 41: 墙+钥匙锁
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 0,
    endRow: 7, endCol: 7,
    bufferSteps: 3,
    specialTiles: [
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 6, col: 4, type: TileType.wall),
      Tile(row: 0, col: 5, type: TileType.key),
      Tile(row: 4, col: 3, type: TileType.lock),
    ],
  );

  // Level 42: 墙+钥匙锁
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 7,
    endRow: 7, endCol: 0,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 4, type: TileType.wall),
      Tile(row: 2, col: 4, type: TileType.wall),
      Tile(row: 5, col: 3, type: TileType.wall),
      Tile(row: 6, col: 3, type: TileType.wall),
      Tile(row: 3, col: 5, type: TileType.key),
      Tile(row: 4, col: 2, type: TileType.lock),
    ],
  );

  // Level 43: 墙+传送
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 0,
    endRow: 7, endCol: 7,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 2, col: 1, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
      Tile(row: 5, col: 6, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.teleport, teleportId: 'l'),
      Tile(row: 6, col: 3, type: TileType.teleport, teleportId: 'l'),
    ],
  );

  // Level 44: 墙+传送+钥匙锁
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 7, startCol: 7,
    endRow: 0, endCol: 0,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 2, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
      Tile(row: 6, col: 5, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.teleport, teleportId: 'm'),
      Tile(row: 4, col: 4, type: TileType.teleport, teleportId: 'm'),
      Tile(row: 1, col: 5, type: TileType.key),
      Tile(row: 6, col: 2, type: TileType.lock),
    ],
  );

  // Level 45: 双钥匙锁
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 0,
    endRow: 7, endCol: 7,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 6, col: 4, type: TileType.wall),
      Tile(row: 0, col: 5, type: TileType.key),
      Tile(row: 3, col: 5, type: TileType.lock),
      Tile(row: 4, col: 2, type: TileType.key),
      Tile(row: 7, col: 3, type: TileType.lock),
    ],
  );

  // Level 46: 双传送
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 0,
    endRow: 7, endCol: 7,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 6, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.wall),
      Tile(row: 3, col: 4, type: TileType.wall),
      Tile(row: 6, col: 1, type: TileType.wall),
      Tile(row: 6, col: 6, type: TileType.wall),
      Tile(row: 2, col: 2, type: TileType.teleport, teleportId: 'n1'),
      Tile(row: 5, col: 5, type: TileType.teleport, teleportId: 'n1'),
      Tile(row: 2, col: 5, type: TileType.teleport, teleportId: 'n2'),
      Tile(row: 5, col: 2, type: TileType.teleport, teleportId: 'n2'),
    ],
  );

  // Level 47: 墙+传送+钥匙锁
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 7,
    endRow: 7, endCol: 0,
    bufferSteps: 2,
    specialTiles: [
      Tile(row: 0, col: 4, type: TileType.wall),
      Tile(row: 1, col: 4, type: TileType.wall),
      Tile(row: 6, col: 3, type: TileType.wall),
      Tile(row: 7, col: 3, type: TileType.wall),
      Tile(row: 2, col: 5, type: TileType.teleport, teleportId: 'o'),
      Tile(row: 5, col: 2, type: TileType.teleport, teleportId: 'o'),
      Tile(row: 3, col: 5, type: TileType.key),
      Tile(row: 4, col: 2, type: TileType.lock),
    ],
  );

  // Level 48: 墙+双传送+双钥匙锁
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 0,
    endRow: 7, endCol: 7,
    bufferSteps: 1,
    specialTiles: [
      Tile(row: 2, col: 2, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 2, col: 4, type: TileType.wall),
      Tile(row: 5, col: 3, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 5, col: 5, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.teleport, teleportId: 'p1'),
      Tile(row: 6, col: 2, type: TileType.teleport, teleportId: 'p1'),
      Tile(row: 0, col: 6, type: TileType.key),
      Tile(row: 4, col: 2, type: TileType.lock),
      Tile(row: 3, col: 1, type: TileType.key),
      Tile(row: 7, col: 4, type: TileType.lock),
    ],
  );

  // Level 49: 双传送+钥匙锁
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 7, startCol: 0,
    endRow: 0, endCol: 7,
    bufferSteps: 1,
    specialTiles: [
      Tile(row: 1, col: 1, type: TileType.wall),
      Tile(row: 1, col: 6, type: TileType.wall),
      Tile(row: 3, col: 2, type: TileType.wall),
      Tile(row: 3, col: 5, type: TileType.wall),
      Tile(row: 6, col: 1, type: TileType.wall),
      Tile(row: 6, col: 6, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.teleport, teleportId: 'q1'),
      Tile(row: 5, col: 4, type: TileType.teleport, teleportId: 'q1'),
      Tile(row: 2, col: 4, type: TileType.teleport, teleportId: 'q2'),
      Tile(row: 5, col: 3, type: TileType.teleport, teleportId: 'q2'),
      Tile(row: 4, col: 1, type: TileType.key),
      Tile(row: 3, col: 6, type: TileType.lock),
    ],
  );

  // Level 50: 终极关
  map[idx++] = _LevelDef(
    rows: 8, cols: 8,
    startRow: 0, startCol: 0,
    endRow: 7, endCol: 7,
    bufferSteps: 1,
    specialTiles: [
      Tile(row: 1, col: 3, type: TileType.wall),
      Tile(row: 2, col: 3, type: TileType.wall),
      Tile(row: 3, col: 3, type: TileType.wall),
      Tile(row: 4, col: 4, type: TileType.wall),
      Tile(row: 5, col: 4, type: TileType.wall),
      Tile(row: 6, col: 4, type: TileType.wall),
      Tile(row: 1, col: 5, type: TileType.teleport, teleportId: 'r1'),
      Tile(row: 6, col: 2, type: TileType.teleport, teleportId: 'r1'),
      Tile(row: 3, col: 1, type: TileType.teleport, teleportId: 'r2'),
      Tile(row: 4, col: 6, type: TileType.teleport, teleportId: 'r2'),
      Tile(row: 0, col: 6, type: TileType.key),
      Tile(row: 4, col: 3, type: TileType.lock),
      Tile(row: 3, col: 5, type: TileType.key),
      Tile(row: 7, col: 2, type: TileType.lock),
    ],
  );

  return map;
}
