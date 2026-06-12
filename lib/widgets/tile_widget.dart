import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/tile.dart';

class TileWidget extends StatelessWidget {
  final TileType? type;
  final bool visited;
  final bool isPlayer;
  final double size;
  final String? teleportId;
  final bool animateCollapse;

  const TileWidget({
    super.key,
    this.type,
    this.visited = false,
    this.isPlayer = false,
    required this.size,
    this.teleportId,
    this.animateCollapse = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppTheme.tileNormal;
    IconData? icon;
    Color iconColor = Colors.white;
    String? label;

    switch (type) {
      case TileType.wall:
        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: const Color(0xFF2A2A2A),
              width: 1.5,
            ),
          ),
        );
      case TileType.start:
        bgColor = AppTheme.tileStart;
        break;
      case TileType.end:
        bgColor = AppTheme.tileEnd;
        icon = Icons.flag;
        iconColor = Colors.black87;
        break;
      case TileType.teleport:
        bgColor = AppTheme.tileTeleport;
        icon = Icons.autorenew;
        label = teleportId;
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
        bgColor = visited ? AppTheme.tileVisited : AppTheme.tileNormal;
    }

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: visited
            ? null
            : [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.3),
                  blurRadius: isPlayer ? 12 : 4,
                  spreadRadius: isPlayer ? 2 : 0,
                ),
              ],
      ),
      child: Stack(
        children: [
          if (icon != null)
            Center(
              child: Icon(icon, color: iconColor, size: size * 0.35),
            ),
          if (label != null)
            Positioned(
              bottom: 4,
              right: 6,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.2,
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isPlayer)
            Center(
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (animateCollapse && visited) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 150),
        tween: Tween(begin: 1.0, end: 0.7),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: content,
      );
    }

    return content;
  }
}
