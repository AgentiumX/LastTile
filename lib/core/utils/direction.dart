enum Direction {
  up,
  down,
  left,
  right,
}

extension DirectionOffset on Direction {
  int get dx => switch (this) {
        Direction.up => 0,
        Direction.down => 0,
        Direction.left => -1,
        Direction.right => 1,
      };

  int get dy => switch (this) {
        Direction.up => -1,
        Direction.down => 1,
        Direction.left => 0,
        Direction.right => 0,
      };
}
