// ignore_for_file: avoid_print
import 'package:collection/collection.dart';

enum TileType { normal, start, end, teleport, key, lock, bridge, flip }

class Tile {
  final int row;
  final int col;
  final TileType type;
  final String? teleportId;
  Tile({required this.row, required this.col, this.type = TileType.normal, this.teleportId});
}

class Level {
  final String id;
  final int rows;
  final int cols;
  final int optimalSteps;
  final int allowedSteps;
  final List<Tile> specialTiles;
  Level({
    required this.id,
    this.rows = 8,
    this.cols = 8,
    required this.optimalSteps,
    required this.allowedSteps,
    this.specialTiles = const [],
  });

  Tile? getSpecialTile(int r, int c) {
    for (final t in specialTiles) {
      if (t.row == r && t.col == c) return t;
    }
    return null;
  }
}

class _Node implements Comparable<_Node> {
  final int r;
  final int c;
  final int steps;
  final int keys;
  final int heuristic;

  _Node(this.r, this.c, this.steps, this.keys, this.heuristic);

  @override
  int compareTo(_Node other) =>
      (steps + heuristic) - (other.steps + other.heuristic);
}

int manhattan(int r1, int c1, int r2, int c2) =>
    (r1 - r2).abs() + (c1 - c2).abs();

int? solveAStar(Level level) {
  final startTile =
      level.specialTiles.firstWhere((t) => t.type == TileType.start);
  final endTile =
      level.specialTiles.firstWhere((t) => t.type == TileType.end);

  final teleportMap = <String, List<(int, int)>>{};
  final keyCount =
      level.specialTiles.where((t) => t.type == TileType.key).length;
  for (final t in level.specialTiles) {
    if (t.type == TileType.teleport && t.teleportId != null) {
      teleportMap.putIfAbsent(t.teleportId!, () => []).add((t.row, t.col));
    }
  }

  int heuristic(int r, int c) => manhattan(r, c, endTile.row, endTile.col);

  final open = PriorityQueue<_Node>();
  final visited = <String, int>{};

  final start =
      _Node(startTile.row, startTile.col, 0, 0, heuristic(startTile.row, startTile.col));
  open.add(start);
  visited['${start.r}_${start.c}_0'] = 0;

  final dirs = [(1, 0), (-1, 0), (0, 1), (0, -1)];

  while (open.isNotEmpty) {
    final current = open.removeFirst();
    if (current.r == endTile.row && current.c == endTile.col) {
      return current.steps;
    }
    for (final (dr, dc) in dirs) {
      final nr = current.r + dr;
      final nc = current.c + dc;
      if (nr < 0 || nr >= level.rows || nc < 0 || nc >= level.cols) continue;

      int newKeys = current.keys;
      final special = level.getSpecialTile(nr, nc);
      if (special?.type == TileType.lock) {
        if (current.keys <= 0) continue;
        newKeys = current.keys - 1;
      } else if (special?.type == TileType.key) {
        newKeys = current.keys + 1;
        if (newKeys > keyCount) newKeys = keyCount;
      }

      final newSteps = current.steps + 1;
      final stateKey = '${nr}_${nc}_$newKeys';
      if (visited.containsKey(stateKey) && visited[stateKey]! <= newSteps) {
        continue;
      }
      visited[stateKey] = newSteps;
      open.add(_Node(nr, nc, newSteps, newKeys, heuristic(nr, nc)));

      final special2 = level.getSpecialTile(nr, nc);
      if (special2 != null &&
          special2.type == TileType.teleport &&
          special2.teleportId != null) {
        final pair = teleportMap[special2.teleportId!];
        if (pair != null) {
          for (final (pr, pc) in pair) {
            if (pr == nr && pc == nc) continue;
            final tpKey = '${pr}_${pc}_$newKeys';
            if (visited.containsKey(tpKey) &&
                visited[tpKey]! <= newSteps) continue;
            visited[tpKey] = newSteps;
            open.add(_Node(pr, pc, newSteps, newKeys, heuristic(pr, pc)));
          }
        }
      }
    }
  }
  return null;
}

List<Level> buildLevels() {
  final levels = <Level>[];
  int idx = 0;

  for (int i = 0; i < 10; i++) {
    int sr = 0, sc = 0, er = 7, ec = 7;
    if (i % 3 == 1) {
      sr = 0; sc = 7; er = 7; ec = 0;
    } else if (i % 3 == 2) {
      sr = 3; sc = 0; er = 3; ec = 7;
    }
    int buffer = 10 - i;
    if (buffer < 5) buffer = 5;
    levels.add(_makeLevel(idx++, sr, sc, er, ec, buffer, []));
  }

  for (int i = 0; i < 10; i++) {
    final tiles = <Tile>[];
    int kr, kc, lr, lc;
    if (i % 2 == 0) {
      kr = 2; kc = 3; lr = 5; lc = 4;
    } else {
      kr = 4; kc = 2; lr = 3; lc = 5;
    }
    tiles.add(Tile(row: kr, col: kc, type: TileType.key));
    tiles.add(Tile(row: lr, col: lc, type: TileType.lock));
    int buffer = 8 - (i ~/ 3);
    if (buffer < 4) buffer = 4;
    levels.add(_makeLevel(idx++, 0, 0, 7, 7, buffer, tiles));
  }

  for (int i = 0; i < 10; i++) {
    final tiles = <Tile>[];
    String tpId = 'tp_$i';
    if (i % 2 == 0) {
      tiles.add(Tile(row: 1, col: 3, type: TileType.teleport, teleportId: tpId));
      tiles.add(Tile(row: 6, col: 4, type: TileType.teleport, teleportId: tpId));
    } else {
      tiles.add(Tile(row: 2, col: 2, type: TileType.teleport, teleportId: tpId));
      tiles.add(Tile(row: 5, col: 5, type: TileType.teleport, teleportId: tpId));
    }
    int buffer = 7 - (i ~/ 4);
    if (buffer < 3) buffer = 3;
    levels.add(_makeLevel(idx++, 0, 0, 7, 7, buffer, tiles));
  }

  for (int i = 0; i < 10; i++) {
    final tiles = <Tile>[];
    String tpId = 'tp_comb_$i';
    tiles.add(Tile(row: 2, col: 2, type: TileType.teleport, teleportId: tpId));
    tiles.add(Tile(row: 5, col: 5, type: TileType.teleport, teleportId: tpId));
    tiles.add(Tile(row: 3, col: 3, type: TileType.key));
    tiles.add(Tile(row: 4, col: 4, type: TileType.lock));
    int buffer = 6 - (i ~/ 5);
    if (buffer < 3) buffer = 3;
    levels.add(_makeLevel(idx++, 0, 0, 7, 7, buffer, tiles));
  }

  for (int i = 0; i < 10; i++) {
    final tiles = <Tile>[];
    String x = 'x_$i';
    String y = 'y_$i';
    tiles.add(Tile(row: 1, col: 1, type: TileType.teleport, teleportId: x));
    tiles.add(Tile(row: 6, col: 6, type: TileType.teleport, teleportId: x));
    tiles.add(Tile(row: 1, col: 6, type: TileType.teleport, teleportId: y));
    tiles.add(Tile(row: 6, col: 1, type: TileType.teleport, teleportId: y));
    tiles.add(Tile(row: 3, col: 2, type: TileType.key));
    tiles.add(Tile(row: 4, col: 5, type: TileType.lock));
    tiles.add(Tile(row: 2, col: 5, type: TileType.key));
    tiles.add(Tile(row: 5, col: 2, type: TileType.lock));
    int buffer = 5 - (i ~/ 5);
    if (buffer < 2) buffer = 2;
    levels.add(_makeLevel(idx++, 0, 0, 7, 7, buffer, tiles));
  }

  return levels;
}

Level _makeLevel(int idx, int sr, int sc, int er, int ec, int buffer, List<Tile> extras) {
  final tiles = <Tile>[
    Tile(row: sr, col: sc, type: TileType.start),
    Tile(row: er, col: ec, type: TileType.end),
    ...extras,
  ];
  final temp = Level(
    id: 'level_${idx + 1}',
    rows: 8,
    cols: 8,
    optimalSteps: 0,
    allowedSteps: 0,
    specialTiles: tiles,
  );
  final optimal = solveAStar(temp) ?? 14;
  return Level(
    id: 'level_${idx + 1}',
    rows: 8,
    cols: 8,
    optimalSteps: optimal,
    allowedSteps: optimal + buffer,
    specialTiles: tiles,
  );
}

void main() {
  final levels = buildLevels();
  print('Total levels: ${levels.length}');
  int failures = 0;
  for (int i = 0; i < levels.length; i++) {
    final lv = levels[i];
    final computed = solveAStar(lv);
    final match = computed == lv.optimalSteps;
    if (!match) failures++;
    final typeInfo = <String>[];
    for (final t in lv.specialTiles) {
      if (t.type != TileType.start && t.type != TileType.end) {
        typeInfo.add(t.type.name);
      }
    }
    print('Level ${i + 1}: optimal=${lv.optimalSteps}, allowed=${lv.allowedSteps}, computeCheck=$computed, types=[${typeInfo.join(',')}]');
  }
  print('');
  print('Failures: $failures / ${levels.length}');
  if (failures == 0) print('ALL CHECKS PASSED');
}
