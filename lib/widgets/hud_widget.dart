import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/game_state.dart';

class HudWidget extends StatelessWidget {
  final GameState state;
  final int levelIndex;
  final int? bestSteps;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const HudWidget({
    super.key,
    required this.state,
    required this.levelIndex,
    this.bestSteps,
    required this.onRestart,
    required this.onHome,
  });

  String get _hint {
    final steps = state.currentSteps;
    if (steps == 0) {
      return '走到终点，走过的格子会消失';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: AppTheme.textPrimary),
                onPressed: onHome,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '第 ${levelIndex + 1} 关',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '剩余 ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${state.remainingSteps}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: state.remainingSteps <= 3
                              ? AppTheme.accent
                              : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        ' 步',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '最优: ${state.level.optimalSteps}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (bestSteps != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '最佳: $bestSteps',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
                onPressed: onRestart,
              ),
            ],
          ),
          if (_hint.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _hint,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.tileEnd.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
