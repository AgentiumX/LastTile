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
                '极简策略解谜',
                style: Theme.of(context).textTheme.bodyMedium,
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
                    return _LevelButton(
                      level: index + 1,
                      stars: score.stars ?? 0,
                      best: score.bestSteps,
                      unlocked: isUnlocked,
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
  final VoidCallback? onTap;

  const _LevelButton({
    required this.level,
    required this.stars,
    this.best,
    required this.unlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: unlocked ? AppTheme.surface : AppTheme.tileVisited,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: unlocked ? AppTheme.primary.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$level',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: unlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return Icon(
                  Icons.star,
                  size: 10,
                  color: i < stars ? AppTheme.tileEnd : Colors.grey.withOpacity(0.3),
                );
              }),
            ),
            if (best != null)
              Text(
                '$best步',
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
