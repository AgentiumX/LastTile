import 'dart:math';

import '../models/level.dart';
import '../models/tile.dart';
import 'path_solver.dart';

class LevelGenerator {
  final Random _rand = Random();

  Level generate({
    String id = 'generated',
    int rows = 8,
    int cols = 8,
    int difficulty = 0,
  }) {
    for (int attempt = 0; attempt < 100; attempt++) {
      final level = _tryGenerate(id, rows, cols, difficulty);
      if (level != null) return level;
    }
    return _createTrivialLevel(id, rows, cols);
  }

  Level? _tryGenerate(String id, int rows, int cols, int difficulty) {
    final tiles = <Tile>[];

    final startRow = _rand.nextInt(rows);
    final startCol = _rand.nextInt(cols);
    tiles.add(Tile(row: startRow, col: startCol, type: TileType.start));

    int endRow = _rand.nextInt(rows);
    int endCol = _rand.nextInt(cols);
    int safetyCount = 0;
    while ((endRow == startRow && endCol == startCol) && safetyCount < 100) {
      endRow = _rand.nextInt(rows);
      endCol = _rand.nextInt(cols);
      safetyCount++;
    }
    tiles.add(Tile(row: endRow, col: endCol, type: TileType.end));

    final pathLength =
        (startRow - endRow).abs() + (startCol - endCol).abs() + _rand.nextInt(4);

    int extraBuffer = 8;
    if (difficulty == 0) extraBuffer = 10;
    if (difficulty == 1) extraBuffer = 7;
    if (difficulty == 2) extraBuffer = 5;
    if (difficulty >= 3) extraBuffer = 3;

    final allowedSteps = pathLength + extraBuffer;

    final tempLevel = Level(
      id: id,
      rows: rows,
      cols: cols,
      optimalSteps: pathLength,
      allowedSteps: allowedSteps,
      specialTiles: tiles,
    );

    final optimal = PathSolver.findOptimalSteps(tempLevel);
    if (optimal == null) return null;

    return Level(
      id: id,
      rows: rows,
      cols: cols,
      optimalSteps: optimal,
      allowedSteps: optimal + extraBuffer,
      specialTiles: tiles,
    );
  }

  Level _createTrivialLevel(String id, int rows, int cols) {
    final tiles = <Tile>[
      Tile(row: 0, col: 0, type: TileType.start),
      Tile(row: rows - 1, col: cols - 1, type: TileType.end),
    ];
    final optimal = (rows - 1) + (cols - 1);
    return Level(
      id: id,
      rows: rows,
      cols: cols,
      optimalSteps: optimal,
      allowedSteps: optimal + 5,
      specialTiles: tiles,
    );
  }
}
