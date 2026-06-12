enum TileType {
  normal,
  wall,
  start,
  end,
  teleport,
  key,
  lock,
  bridge,
  flip,
}

class Tile {
  final int row;
  final int col;
  final TileType type;
  final String? teleportId;
  bool visited;

  Tile({
    required this.row,
    required this.col,
    this.type = TileType.normal,
    this.teleportId,
    this.visited = false,
  });

  Tile copyWith({
    int? row,
    int? col,
    TileType? type,
    String? teleportId,
    bool? visited,
  }) {
    return Tile(
      row: row ?? this.row,
      col: col ?? this.col,
      type: type ?? this.type,
      teleportId: teleportId ?? this.teleportId,
      visited: visited ?? this.visited,
    );
  }

  factory Tile.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String?) ?? 'normal';
    final type = _parseTileType(typeStr);
    return Tile(
      row: json['row'] as int,
      col: json['col'] as int,
      type: type,
      teleportId: json['teleportId'] as String?,
      visited: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'type': _tileTypeToString(type),
      if (teleportId != null) 'teleportId': teleportId,
    };
  }

  static TileType _parseTileType(String str) {
    switch (str.toLowerCase()) {
      case 'wall':
        return TileType.wall;
      case 'start':
        return TileType.start;
      case 'end':
        return TileType.end;
      case 'teleport':
        return TileType.teleport;
      case 'key':
        return TileType.key;
      case 'lock':
        return TileType.lock;
      case 'bridge':
        return TileType.bridge;
      case 'flip':
        return TileType.flip;
      default:
        return TileType.normal;
    }
  }

  static String _tileTypeToString(TileType type) {
    switch (type) {
      case TileType.wall:
        return 'wall';
      case TileType.start:
        return 'start';
      case TileType.end:
        return 'end';
      case TileType.teleport:
        return 'teleport';
      case TileType.key:
        return 'key';
      case TileType.lock:
        return 'lock';
      case TileType.bridge:
        return 'bridge';
      case TileType.flip:
        return 'flip';
      default:
        return 'normal';
    }
  }
}
