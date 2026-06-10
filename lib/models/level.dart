import 'tile.dart';

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

  factory Level.fromJson(Map<String, dynamic> json) {
    final tilesList = json['tiles'] as List<dynamic>? ?? [];
    final tiles = tilesList
        .map((t) => Tile.fromJson(t as Map<String, dynamic>))
        .toList();
    return Level(
      id: json['id'] as String,
      rows: (json['rows'] as int?) ?? 8,
      cols: (json['cols'] as int?) ?? 8,
      optimalSteps: json['optimalSteps'] as int,
      allowedSteps: json['allowedSteps'] as int,
      specialTiles: tiles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rows': rows,
      'cols': cols,
      'optimalSteps': optimalSteps,
      'allowedSteps': allowedSteps,
      'tiles': specialTiles.map((t) => t.toJson()).toList(),
    };
  }

  Tile? getSpecialTile(int row, int col) {
    for (final tile in specialTiles) {
      if (tile.row == row && tile.col == col) return tile;
    }
    return null;
  }

  Tile? get startTile {
    for (final tile in specialTiles) {
      if (tile.type == TileType.start) return tile;
    }
    return null;
  }

  Tile? get endTile {
    for (final tile in specialTiles) {
      if (tile.type == TileType.end) return tile;
    }
    return null;
  }
}
