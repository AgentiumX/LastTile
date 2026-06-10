import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../engine/game_engine.dart';
import '../models/game_state.dart';

class ResultScreen extends StatelessWidget {
  final GameState state;
  final VoidCallback onRestart;
  final VoidCallback onNext;
  final VoidCallback onHome;

  const ResultScreen({
    super.key,
    required this.state,
    required this.onRestart,
    required this.onNext,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = state.status == GameStatus.completed;
    final engine = GameEngine();
    final stars = isSuccess
        ? engine.calculateStars(state.currentSteps, state.level.optimalSteps)
        : 0;

    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSuccess ? '关卡完成' : '再来一次',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          if (isSuccess)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return Icon(
                  Icons.star,
                  size: 32,
                  color: i < stars
                      ? AppTheme.tileEnd
                      : Colors.grey.withOpacity(0.3),
                );
              }),
            ),
          const SizedBox(height: 20),
          Text(
            '使用步数: ${state.currentSteps}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '最优步数: ${state.level.optimalSteps}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (!isSuccess && state.distanceToEnd != null)
            Text(
              state.lastFeedback ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.accent,
                  ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildButton(Icons.home, '主页', onHome),
              _buildButton(Icons.refresh, '重试', onRestart),
              if (isSuccess) _buildButton(Icons.arrow_forward, '下一关', onNext),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
