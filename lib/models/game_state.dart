import '../models/level.dart';
import '../models/player.dart';
import '../models/tile.dart';

enum GameStatus {
  playing,
  completed,
  failed,
}

class GameState {
  final Level level;
  final Player player;
  final Map<String, bool> visitedMap;
  final List<Tile> dynamicTiles;
  final int remainingSteps;
  final int currentSteps;
  final GameStatus status;
  final int? distanceToEnd;
  final String? lastFeedback;

  GameState({
    required this.level,
    required this.player,
    required this.visitedMap,
    required this.dynamicTiles,
    required this.remainingSteps,
    required this.currentSteps,
    required this.status,
    this.distanceToEnd,
    this.lastFeedback,
  });

  String tileKey(int row, int col) => '${row}_$col';

  bool isVisited(int row, int col) => visitedMap[tileKey(row, col)] ?? false;

  bool isInBounds(int row, int col) {
    return row >= 0 && row < level.rows && col >= 0 && col < level.cols;
  }

  Tile? getTile(int row, int col) {
    for (final t in dynamicTiles) {
      if (t.row == row && t.col == col) return t;
    }
    return level.getSpecialTile(row, col);
  }

  GameState copyWith({
    Level? level,
    Player? player,
    Map<String, bool>? visitedMap,
    List<Tile>? dynamicTiles,
    int? remainingSteps,
    int? currentSteps,
    GameStatus? status,
    int? distanceToEnd,
    String? lastFeedback,
  }) {
    return GameState(
      level: level ?? this.level,
      player: player ?? this.player,
      visitedMap: visitedMap ?? this.visitedMap,
      dynamicTiles: dynamicTiles ?? this.dynamicTiles,
      remainingSteps: remainingSteps ?? this.remainingSteps,
      currentSteps: currentSteps ?? this.currentSteps,
      status: status ?? this.status,
      distanceToEnd: distanceToEnd ?? this.distanceToEnd,
      lastFeedback: lastFeedback ?? this.lastFeedback,
    );
  }

  static GameState initial(Level level) {
    final start = level.startTile;
    final playerRow = start?.row ?? 0;
    final playerCol = start?.col ?? 0;
    final state = GameState(
      level: level,
      player: Player(row: playerRow, col: playerCol),
      visitedMap: {},
      dynamicTiles: [],
      remainingSteps: level.allowedSteps,
      currentSteps: 0,
      status: GameStatus.playing,
    );
    state.visitedMap[state.tileKey(playerRow, playerCol)] = true;
    return state;
  }
}
