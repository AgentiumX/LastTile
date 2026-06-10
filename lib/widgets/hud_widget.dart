import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/game_state.dart';

class HudWidget extends StatelessWidget {
  final GameState state;
  final int? bestSteps;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const HudWidget({
    super.key,
    required this.state,
    this.bestSteps,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
                '剩余步数',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${state.remainingSteps}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: state.remainingSteps <= 3
                          ? AppTheme.accent
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '最优: ${state.level.optimalSteps}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (bestSteps != null)
                Text(
                  '最佳: $bestSteps',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                      ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }
}
