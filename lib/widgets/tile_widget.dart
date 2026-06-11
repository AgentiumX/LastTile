import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/tile.dart';

class TileWidget extends StatelessWidget {
  final TileType? type;
  final bool visited;
  final bool isPlayer;
  final double size;
  final String? teleportId;

  const TileWidget({
    super.key,
    this.type,
    this.visited = false,
    this.isPlayer = false,
    required this.size,
    this.teleportId,
  });

  @override
  Widget build(BuildContext context) {
    // 已访问且非玩家位置 = 已坍塌
    if (visited && !isPlayer) {
      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFF222222),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.close,
            size: size * 0.2,
            color: const Color(0xFF333333),
          ),
        ),
      );
    }

    Color bgColor = AppTheme.tileNormal;
    IconData? icon;
    Color iconColor = Colors.white;

    switch (type) {
      case TileType.start:
        bgColor = AppTheme.tileStart;
        icon = Icons.play_arrow;
        iconColor = Colors.white;
        break;
      case TileType.end:
        bgColor = AppTheme.tileEnd;
        icon = Icons.flag;
        iconColor = Colors.black87;
        break;
      case TileType.teleport:
        bgColor = AppTheme.tileTeleport;
        icon = Icons.autorenew;
        break;
      case TileType.key:
        bgColor = AppTheme.tileKey;
        icon = Icons.vpn_key;
        break;
      case TileType.lock:
        bgColor = AppTheme.tileLock;
        icon = Icons.lock;
        break;
      case TileType.bridge:
        bgColor = Colors.brown;
        icon = Icons.linear_scale;
        break;
      case TileType.flip:
        bgColor = Colors.teal;
        icon = Icons.autorenew;
        break;
      default:
        bgColor = AppTheme.tileNormal;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: isPlayer ? 12 : 3,
            spreadRadius: isPlayer ? 2 : 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          if (icon != null && !isPlayer)
            Center(
              child: Icon(icon, color: iconColor, size: size * 0.35),
            ),
          if (isPlayer)
            Center(
              child: Container(
                width: size * 0.45,
                height: size * 0.45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
