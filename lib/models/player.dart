class Player {
  int row;
  int col;
  int keys;

  Player({
    required this.row,
    required this.col,
    this.keys = 0,
  });

  Player copyWith({
    int? row,
    int? col,
    int? keys,
  }) {
    return Player(
      row: row ?? this.row,
      col: col ?? this.col,
      keys: keys ?? this.keys,
    );
  }
}
