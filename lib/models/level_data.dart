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
  final int startRow;
  final int startCol;
  final int endRow;
  final int endCol;
  final int bufferSteps;
  final List<Tile> specialTiles;

  _LevelDef({
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
      rows: 8,
      cols: 8,
      optimalSteps: 0,
      allowedSteps: 0,
      specialTiles: tiles,
    );

    final optimal = PathSolver.findOptimalSteps(temp) ??
        ((endRow - startRow).abs() + (endCol - startCol).abs());

    return Level(
      id: 'level_${index + 1}',
      rows: 8,
      cols: 8,
      optimalSteps: optimal,
      allowedSteps: optimal + bufferSteps,
      specialTiles: tiles,
    );
  }
}

Map<int, _LevelDef> _buildAllLevels() {
  final map = <int, _LevelDef>{};
  int idx = 0;

  for (int i = 0; i < 10; i++) {
    int sr = 0, sc = 0;
    int er = 7, ec = 7;
    if (i % 3 == 1) {
      sr = 0; sc = 7; er = 7; ec = 0;
    } else if (i % 3 == 2) {
      sr = 3; sc = 0; er = 3; ec = 7;
    }
    int buffer = 10 - i;
    if (buffer < 5) buffer = 5;
    map[idx++] = _LevelDef(
      startRow: sr, startCol: sc,
      endRow: er, endCol: ec,
      bufferSteps: buffer,
    );
  }

  for (int i = 0; i < 10; i++) {
    final tiles = <Tile>[];
    int keyR, keyC, lockR, lockC;
    if (i % 2 == 0) {
      keyR = 2; keyC = 3;
      lockR = 5; lockC = 4;
    } else {
      keyR = 4; keyC = 2;
      lockR = 3; lockC = 5;
    }
    tiles.add(Tile(row: keyR, col: keyC, type: TileType.key));
    tiles.add(Tile(row: lockR, col: lockC, type: TileType.lock));

    int buffer = 8 - (i ~/ 3);
    if (buffer < 4) buffer = 4;
    map[idx++] = _LevelDef(
      startRow: 0, startCol: 0,
      endRow: 7, endCol: 7,
      bufferSteps: buffer,
      specialTiles: tiles,
    );
  }

  for (int i = 0; i < 10; i++) {
    final tiles = <Tile>[];
    if (i % 2 == 0) {
      tiles.add(Tile(row: 1, col: 3, type: TileType.teleport, teleportId: 't1'));
      tiles.add(Tile(row: 6, col: 4, type: TileType.teleport, teleportId: 't1'));
    } else {
      tiles.add(Tile(row: 2, col: 2, type: TileType.teleport, teleportId: 'a'));
      tiles.add(Tile(row: 5, col: 5, type: TileType.teleport, teleportId: 'a'));
    }

    int buffer = 7 - (i ~/ 4);
    if (buffer < 3) buffer = 3;
    map[idx++] = _LevelDef(
      startRow: 0, startCol: 0,
      endRow: 7, endCol: 7,
      bufferSteps: buffer,
      specialTiles: tiles,
    );
  }

  for (int i = 0; i < 10; i++) {
    final tiles = <Tile>[];
    tiles.add(Tile(row: 2, col: 2, type: TileType.teleport, teleportId: 'tp_$i'));
    tiles.add(Tile(row: 5, col: 5, type: TileType.teleport, teleportId: 'tp_$i'));
    tiles.add(Tile(row: 3, col: 3, type: TileType.key));
    tiles.add(Tile(row: 4, col: 4, type: TileType.lock));

    int buffer = 6 - (i ~/ 5);
    if (buffer < 3) buffer = 3;
    map[idx++] = _LevelDef(
      startRow: 0, startCol: 0,
      endRow: 7, endCol: 7,
      bufferSteps: buffer,
      specialTiles: tiles,
    );
  }

  for (int i = 0; i < 10; i++) {
    final tiles = <Tile>[];
    tiles.add(Tile(row: 1, col: 1, type: TileType.teleport, teleportId: 'x_$i'));
    tiles.add(Tile(row: 6, col: 6, type: TileType.teleport, teleportId: 'x_$i'));
    tiles.add(Tile(row: 1, col: 6, type: TileType.teleport, teleportId: 'y_$i'));
    tiles.add(Tile(row: 6, col: 1, type: TileType.teleport, teleportId: 'y_$i'));
    tiles.add(Tile(row: 3, col: 2, type: TileType.key));
    tiles.add(Tile(row: 4, col: 5, type: TileType.lock));
    tiles.add(Tile(row: 2, col: 5, type: TileType.key));
    tiles.add(Tile(row: 5, col: 2, type: TileType.lock));

    int buffer = 5 - (i ~/ 5);
    if (buffer < 2) buffer = 2;
    map[idx++] = _LevelDef(
      startRow: 0, startCol: 0,
      endRow: 7, endCol: 7,
      bufferSteps: buffer,
      specialTiles: tiles,
    );
  }

  return map;
}
