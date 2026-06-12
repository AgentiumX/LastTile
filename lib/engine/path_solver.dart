import 'dart:collection';

import '../models/level.dart';
import '../models/tile.dart';

class _Node implements Comparable<_Node> {
  final int row;
  final int col;
  final int steps;
  final int heuristic;
  final int keys;

  _Node({
    required this.row,
    required this.col,
    required this.steps,
    required this.heuristic,
    required this.keys,
  });

  int get priority => steps + heuristic;

  @override
  int compareTo(_Node other) => priority - other.priority;

  String get key => '${row}_${col}_${keys}';
}

class PathSolver {
  static int manhattan(int r1, int c1, int r2, int c2) {
    return (r1 - r2).abs() + (c1 - c2).abs();
  }

  static List<(int, int)> _neighbors(int row, int col) {
    return [
      (row - 1, col),
      (row + 1, col),
      (row, col - 1),
      (row, col + 1),
    ];
  }

  static int? solveAStar(Level level) {
    final start = level.startTile;
    final end = level.endTile;
    if (start == null || end == null) return null;

    final teleportMap = <String, List<(int, int)>>{};
    final keyPositions = <(int, int)>{};
    final lockPositions = <(int, int)>{};

    for (final t in level.specialTiles) {
      if (t.type == TileType.teleport && t.teleportId != null) {
        teleportMap.putIfAbsent(t.teleportId!, () => []).add((t.row, t.col));
      } else if (t.type == TileType.key) {
        keyPositions.add((t.row, t.col));
      } else if (t.type == TileType.lock) {
        lockPositions.add((t.row, t.col));
      }
    }

    final totalKeys = keyPositions.length;

    int heuristic(int r, int c, int k) {
      return manhattan(r, c, end.row, end.col);
    }

    final open = PriorityQueue<_Node>();
    final visitedStates = <String, int>{};

    final startNode = _Node(
      row: start.row,
      col: start.col,
      steps: 0,
      heuristic: heuristic(start.row, start.col, 0),
      keys: 0,
    );
    open.add(startNode);
    visitedStates[startNode.key] = 0;

    while (open.isNotEmpty) {
      final current = open.removeFirst();

      if (current.row == end.row && current.col == end.col) {
        return current.steps;
      }

      for (final (nr, nc) in _neighbors(current.row, current.col)) {
        if (nr < 0 || nr >= level.rows || nc < 0 || nc >= level.cols) continue;

        final neighborTile = level.getSpecialTile(nr, nc);
        if (neighborTile != null && neighborTile.type == TileType.wall) continue;

        int newKeys = current.keys;
        final specialTile = level.getSpecialTile(nr, nc);

        if (specialTile != null) {
          if (specialTile.type == TileType.lock) {
            if (current.keys <= 0) continue;
            newKeys = current.keys - 1;
          } else if (specialTile.type == TileType.key) {
            newKeys = current.keys + 1;
            if (newKeys > totalKeys) newKeys = totalKeys;
          }
        }

        final newSteps = current.steps + 1;
        final stateKey = '${nr}_${nc}_${newKeys}';

        if (visitedStates.containsKey(stateKey) &&
            visitedStates[stateKey]! <= newSteps) continue;
        visitedStates[stateKey] = newSteps;

        open.add(_Node(
          row: nr,
          col: nc,
          steps: newSteps,
          heuristic: heuristic(nr, nc, newKeys),
          keys: newKeys,
        ));

        final special = level.getSpecialTile(nr, nc);
        if (special != null &&
            special.type == TileType.teleport &&
            special.teleportId != null) {
          final pair = teleportMap[special.teleportId!];
          if (pair != null) {
            for (final (pr, pc) in pair) {
              if (pr == nr && pc == nc) continue;
              final tpKey = '${pr}_${pc}_${newKeys}';
              if (visitedStates.containsKey(tpKey) &&
                  visitedStates[tpKey]! <= newSteps) continue;
              visitedStates[tpKey] = newSteps;
              open.add(_Node(
                row: pr,
                col: pc,
                steps: newSteps,
                heuristic: heuristic(pr, pc, newKeys),
                keys: newKeys,
              ));
            }
          }
        }
      }
    }

    return null;
  }

  static bool hasSolution(Level level) {
    return solveAStar(level) != null;
  }

  static int? findOptimalSteps(Level level) {
    return solveAStar(level);
  }

  static int remainingDistanceEstimate(
    Level level,
    int currentRow,
    int currentCol,
  ) {
    final end = level.endTile;
    if (end == null) return 0;
    return manhattan(currentRow, currentCol, end.row, end.col);
  }
}
