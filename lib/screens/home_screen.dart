import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../screens/level_screen.dart';
import '../state/game_provider.dart';
import '../storage/save_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final total = ref.watch(totalLevelsProvider);
    final unlocked = SaveManager.unlockedLevel;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'LAST TILE',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '走过即消失，步步不可逆',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                    ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 80,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final score = ref.watch(levelScoreProvider(index));
                    final isUnlocked = index <= unlocked;
                    final isCompleted = (score.stars ?? 0) > 0;
                    return _LevelButton(
                      level: index + 1,
                      stars: score.stars ?? 0,
                      best: score.bestSteps,
                      unlocked: isUnlocked,
                      completed: isCompleted,
                      isCurrent: index == unlocked,
                      onTap: isUnlocked
                          ? () => _openLevel(context, index)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLevel(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => LevelScreen(levelIndex: index)),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final int level;
  final int stars;
  final int? best;
  final bool unlocked;
  final bool completed;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _LevelButton({
    required this.level,
    required this.stars,
    this.best,
    required this.unlocked,
    required this.completed,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    double borderWidth;
    Color textColor;

    if (!unlocked) {
      bgColor = const Color(0xFF1A1A1A);
      borderColor = Colors.grey.withOpacity(0.2);
      borderWidth = 1;
      textColor = Colors.grey.withOpacity(0.3);
    } else if (completed) {
      bgColor = AppTheme.tileKey.withOpacity(0.15);
      borderColor = AppTheme.tileKey;
      borderWidth = 2;
      textColor = AppTheme.textPrimary;
    } else if (isCurrent) {
      bgColor = AppTheme.primary.withOpacity(0.15);
      borderColor = AppTheme.primary;
      borderWidth = 2.5;
      textColor = AppTheme.textPrimary;
    } else {
      bgColor = AppTheme.surface;
      borderColor = AppTheme.primary.withOpacity(0.3);
      borderWidth = 1;
      textColor = AppTheme.textPrimary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!unlocked)
              Icon(Icons.lock, size: 18, color: Colors.grey.withOpacity(0.3))
            else
              Text(
                '$level',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            const SizedBox(height: 2),
            if (unlocked)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return Icon(
                    Icons.star,
                    size: 8,
                    color: i < stars
                        ? AppTheme.tileEnd
                        : Colors.grey.withOpacity(0.15),
                  );
                }),
              ),
            if (best != null)
              Text(
                '$best步',
                style: TextStyle(
                  fontSize: 9,
                  color: completed ? AppTheme.tileKey : AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
