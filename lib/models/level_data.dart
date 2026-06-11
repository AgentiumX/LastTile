import '../models/level.dart';
import '../models/tile.dart';
import '../engine/path_solver.dart';

class LevelData {
  static final List<Level> _levels = _buildAllLevels();

  static int get totalLevels => _levels.length;

  static Level getLevel(int index) {
    if (index < 0 || index >= _levels.length) {
      throw RangeError.index(index, _levels, 'level index');
    }
    return _levels[index];
  }

  static List<Level> getAllLevels() => List.unmodifiable(_levels);
}

Level _makeLevel(
  String id,
  int rows,
  int cols,
  int sr,
  int sc,
  int er,
  int ec,
  int buffer,
  List<Tile> extras,
) {
  final tiles = <Tile>[
    Tile(row: sr, col: sc, type: TileType.start),
    Tile(row: er, col: ec, type: TileType.end),
    ...extras,
  ];
  final temp = Level(
    id: id,
    rows: rows,
    cols: cols,
    optimalSteps: 0,
    allowedSteps: 0,
    specialTiles: tiles,
  );
  final optimal = PathSolver.findOptimalSteps(temp) ??
      ((er - sr).abs() + (ec - sc).abs());
  return Level(
    id: id,
    rows: rows,
    cols: cols,
    optimalSteps: optimal,
    allowedSteps: optimal + buffer,
    specialTiles: tiles,
  );
}

List<Level> _buildAllLevels() {
  final levels = <Level>[];
  int n = 0;

  // ===== 第1-3关: 3x3 教学 =====
  // 第1关: 最简单，直线走到终点
  levels.add(_makeLevel('level_${++n}', 3, 3, 0, 0, 2, 2, 5, []));

  // 第2关: 起点在右上
  levels.add(_makeLevel('level_${++n}', 3, 3, 0, 2, 2, 0, 4, []));

  // 第3关: 横向
  levels.add(_makeLevel('level_${++n}', 3, 4, 1, 0, 1, 3, 4, []));

  // ===== 第4-6关: 4x4 入门 =====
  levels.add(_makeLevel('level_${++n}', 4, 4, 0, 0, 3, 3, 5, []));

  levels.add(_makeLevel('level_${++n}', 4, 4, 0, 3, 3, 0, 4, []));

  levels.add(_makeLevel('level_${++n}', 4, 4, 3, 0, 0, 3, 4, [
    Tile(row: 1, col: 2, type: TileType.key),
    Tile(row: 2, col: 1, type: TileType.lock),
  ]));

  // ===== 第7-10关: 5x5 进阶 =====
  levels.add(_makeLevel('level_${++n}', 5, 5, 0, 0, 4, 4, 5, []));

  levels.add(_makeLevel('level_${++n}', 5, 5, 0, 4, 4, 0, 4, [
    Tile(row: 2, col: 2, type: TileType.teleport, teleportId: 'tp1'),
    Tile(row: 3, col: 3, type: TileType.teleport, teleportId: 'tp1'),
  ]));

  levels.add(_makeLevel('level_${++n}', 5, 5, 2, 0, 2, 4, 4, [
    Tile(row: 1, col: 2, type: TileType.key),
    Tile(row: 3, col: 3, type: TileType.lock),
  ]));

  levels.add(_makeLevel('level_${++n}', 5, 5, 0, 0, 4, 4, 3, [
    Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'a'),
    Tile(row: 3, col: 3, type: TileType.teleport, teleportId: 'a'),
    Tile(row: 2, col: 3, type: TileType.key),
    Tile(row: 3, col: 1, type: TileType.lock),
  ]));

  // ===== 第11-20关: 6x6 多样化起终点 =====
  levels.add(_makeLevel('level_${++n}', 6, 6, 0, 0, 5, 5, 5, []));
  levels.add(_makeLevel('level_${++n}', 6, 6, 0, 5, 5, 0, 4, []));
  levels.add(_makeLevel('level_${++n}', 6, 6, 5, 0, 0, 5, 4, []));
  levels.add(_makeLevel('level_${++n}', 6, 6, 0, 2, 5, 3, 4, []));
  levels.add(_makeLevel('level_${++n}', 6, 6, 2, 0, 3, 5, 4, []));

  levels.add(_makeLevel('level_${++n}', 6, 6, 0, 0, 5, 5, 4, [
    Tile(row: 2, col: 1, type: TileType.key),
    Tile(row: 4, col: 4, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 6, 6, 0, 5, 5, 0, 3, [
    Tile(row: 1, col: 3, type: TileType.key),
    Tile(row: 4, col: 1, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 6, 6, 0, 0, 5, 5, 3, [
    Tile(row: 1, col: 4, type: TileType.teleport, teleportId: 'b'),
    Tile(row: 4, col: 1, type: TileType.teleport, teleportId: 'b'),
  ]));
  levels.add(_makeLevel('level_${++n}', 6, 6, 5, 5, 0, 0, 3, [
    Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'c'),
    Tile(row: 4, col: 4, type: TileType.teleport, teleportId: 'c'),
    Tile(row: 2, col: 3, type: TileType.key),
    Tile(row: 3, col: 2, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 6, 6, 0, 0, 5, 5, 3, [
    Tile(row: 1, col: 2, type: TileType.key),
    Tile(row: 4, col: 3, type: TileType.lock),
    Tile(row: 2, col: 4, type: TileType.key),
    Tile(row: 3, col: 1, type: TileType.lock),
  ]));

  // ===== 第21-35关: 7x7 =====
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 0, 6, 6, 5, []));
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 6, 6, 0, 4, []));
  levels.add(_makeLevel('level_${++n}', 7, 7, 6, 0, 0, 6, 4, []));
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 3, 6, 3, 4, []));
  levels.add(_makeLevel('level_${++n}', 7, 7, 3, 0, 3, 6, 4, []));

  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 0, 6, 6, 4, [
    Tile(row: 2, col: 2, type: TileType.key),
    Tile(row: 5, col: 4, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 6, 6, 0, 3, [
    Tile(row: 3, col: 3, type: TileType.teleport, teleportId: 'd'),
    Tile(row: 4, col: 4, type: TileType.teleport, teleportId: 'd'),
  ]));
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 0, 6, 6, 3, [
    Tile(row: 1, col: 5, type: TileType.teleport, teleportId: 'e'),
    Tile(row: 5, col: 1, type: TileType.teleport, teleportId: 'e'),
    Tile(row: 2, col: 3, type: TileType.key),
    Tile(row: 4, col: 3, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 7, 7, 6, 6, 0, 0, 3, [
    Tile(row: 2, col: 4, type: TileType.key),
    Tile(row: 4, col: 2, type: TileType.lock),
    Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'f'),
    Tile(row: 5, col: 5, type: TileType.teleport, teleportId: 'f'),
  ]));
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 0, 6, 6, 3, [
    Tile(row: 1, col: 3, type: TileType.key),
    Tile(row: 5, col: 3, type: TileType.lock),
    Tile(row: 3, col: 1, type: TileType.key),
    Tile(row: 3, col: 5, type: TileType.lock),
  ]));

  // 更多7x7变体
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 0, 6, 6, 2, [
    Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'g'),
    Tile(row: 5, col: 5, type: TileType.teleport, teleportId: 'g'),
  ]));
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 6, 6, 0, 2, [
    Tile(row: 1, col: 5, type: TileType.teleport, teleportId: 'h'),
    Tile(row: 5, col: 1, type: TileType.teleport, teleportId: 'h'),
  ]));
  levels.add(_makeLevel('level_${++n}', 7, 7, 3, 0, 3, 6, 3, [
    Tile(row: 1, col: 2, type: TileType.key),
    Tile(row: 5, col: 4, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 3, 6, 3, 2, [
    Tile(row: 2, col: 2, type: TileType.teleport, teleportId: 'i'),
    Tile(row: 4, col: 4, type: TileType.teleport, teleportId: 'i'),
    Tile(row: 3, col: 1, type: TileType.key),
    Tile(row: 3, col: 5, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 7, 7, 0, 0, 6, 6, 2, [
    Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'j1'),
    Tile(row: 5, col: 5, type: TileType.teleport, teleportId: 'j1'),
    Tile(row: 1, col: 5, type: TileType.teleport, teleportId: 'j2'),
    Tile(row: 5, col: 1, type: TileType.teleport, teleportId: 'j2'),
  ]));

  // ===== 第36-50关: 8x8 完整 =====
  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 0, 7, 7, 5, []));
  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 7, 7, 0, 4, []));
  levels.add(_makeLevel('level_${++n}', 8, 8, 7, 0, 0, 7, 4, []));
  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 3, 7, 4, 4, []));
  levels.add(_makeLevel('level_${++n}', 8, 8, 3, 0, 4, 7, 4, []));

  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 0, 7, 7, 4, [
    Tile(row: 2, col: 3, type: TileType.key),
    Tile(row: 5, col: 4, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 7, 7, 0, 3, [
    Tile(row: 4, col: 2, type: TileType.key),
    Tile(row: 3, col: 5, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 0, 7, 7, 3, [
    Tile(row: 1, col: 3, type: TileType.teleport, teleportId: 'k'),
    Tile(row: 6, col: 4, type: TileType.teleport, teleportId: 'k'),
  ]));
  levels.add(_makeLevel('level_${++n}', 8, 8, 7, 7, 0, 0, 3, [
    Tile(row: 2, col: 2, type: TileType.teleport, teleportId: 'l'),
    Tile(row: 5, col: 5, type: TileType.teleport, teleportId: 'l'),
    Tile(row: 3, col: 3, type: TileType.key),
    Tile(row: 4, col: 4, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 0, 7, 7, 3, [
    Tile(row: 2, col: 3, type: TileType.key),
    Tile(row: 5, col: 4, type: TileType.lock),
    Tile(row: 2, col: 5, type: TileType.key),
    Tile(row: 5, col: 2, type: TileType.lock),
  ]));

  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 0, 7, 7, 2, [
    Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'm1'),
    Tile(row: 6, col: 6, type: TileType.teleport, teleportId: 'm1'),
    Tile(row: 1, col: 6, type: TileType.teleport, teleportId: 'm2'),
    Tile(row: 6, col: 1, type: TileType.teleport, teleportId: 'm2'),
  ]));
  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 7, 7, 0, 2, [
    Tile(row: 1, col: 5, type: TileType.teleport, teleportId: 'n'),
    Tile(row: 6, col: 2, type: TileType.teleport, teleportId: 'n'),
    Tile(row: 3, col: 2, type: TileType.key),
    Tile(row: 4, col: 5, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 0, 7, 7, 2, [
    Tile(row: 2, col: 2, type: TileType.teleport, teleportId: 'o1'),
    Tile(row: 5, col: 5, type: TileType.teleport, teleportId: 'o1'),
    Tile(row: 3, col: 3, type: TileType.key),
    Tile(row: 4, col: 4, type: TileType.lock),
    Tile(row: 2, col: 5, type: TileType.key),
    Tile(row: 5, col: 2, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 8, 8, 7, 0, 0, 7, 2, [
    Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'p1'),
    Tile(row: 6, col: 6, type: TileType.teleport, teleportId: 'p1'),
    Tile(row: 1, col: 6, type: TileType.teleport, teleportId: 'p2'),
    Tile(row: 6, col: 1, type: TileType.teleport, teleportId: 'p2'),
    Tile(row: 3, col: 2, type: TileType.key),
    Tile(row: 4, col: 5, type: TileType.lock),
  ]));
  levels.add(_makeLevel('level_${++n}', 8, 8, 0, 0, 7, 7, 1, [
    Tile(row: 1, col: 3, type: TileType.teleport, teleportId: 'q1'),
    Tile(row: 6, col: 4, type: TileType.teleport, teleportId: 'q1'),
    Tile(row: 3, col: 1, type: TileType.teleport, teleportId: 'q2'),
    Tile(row: 4, col: 6, type: TileType.teleport, teleportId: 'q2'),
    Tile(row: 2, col: 3, type: TileType.key),
    Tile(row: 5, col: 4, type: TileType.lock),
    Tile(row: 2, col: 5, type: TileType.key),
    Tile(row: 5, col: 2, type: TileType.lock),
  ]));

  return levels;
}
