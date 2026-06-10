import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/tile.dart';
import 'tile_widget.dart';

class BoardWidget extends StatelessWidget {
  final GameState state;

  const BoardWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxSide = screenSize.width < screenSize.height
        ? screenSize.width
        : screenSize.height * 0.6;
    final padding = 16.0;
    final gap = 4.0;
    final maxDim = state.level.rows > state.level.cols
        ? state.level.rows
        : state.level.cols;
    final tileSize = (maxSide - padding * 2 - gap * maxDim) / maxDim;

    return Container(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(state.level.rows, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(state.level.cols, (col) {
              final specialTile = state.level.getSpecialTile(row, col);
              TileType? displayType;
              String? teleportId;

              if (specialTile != null) {
                displayType = specialTile.type;
                teleportId = specialTile.teleportId;
              }

              final wasVisited = state.isVisited(row, col);
              final isPlayerPos =
                  state.player.row == row && state.player.col == col;

              final dynamicTile = state.getTile(row, col);
              if (dynamicTile != null &&
                  dynamicTile.type == TileType.lock &&
                  wasVisited) {
                displayType = TileType.lock;
              }

              return SizedBox(
                width: tileSize,
                height: tileSize,
                child: TileWidget(
                  type: displayType,
                  visited: wasVisited && !isPlayerPos,
                  isPlayer: isPlayerPos,
                  size: tileSize,
                  teleportId: teleportId,
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
