import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/direction.dart';
import '../engine/level_loader.dart';
import '../models/game_state.dart';
import '../screens/result_screen.dart';
import '../state/game_provider.dart';
import '../widgets/board_widget.dart';
import '../widgets/control_pad.dart';
import '../widgets/hud_widget.dart';

class LevelScreen extends ConsumerStatefulWidget {
  final int levelIndex;
  const LevelScreen({super.key, required this.levelIndex});

  @override
  ConsumerState<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends ConsumerState<LevelScreen> {
  late final FocusNode _focusNode;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).loadLevel(widget.levelIndex);
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleDirection(Direction direction) {
    final notifier = ref.read(gameProvider.notifier);
    notifier.move(direction);
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    Direction? dir;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      dir = Direction.up;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      dir = Direction.down;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      dir = Direction.left;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      dir = Direction.right;
    } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
      ref.read(gameProvider.notifier).restart();
      return;
    }
    if (dir != null) _handleDirection(dir);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);

    if (state != null && !_resultShown) {
      if (state.status == GameStatus.completed ||
          state.status == GameStatus.failed) {
        _resultShown = true;
        Future.microtask(() => _showResult(state));
      }
    }

    if (state == null) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _handleKey,
          child: Column(
            children: [
              HudWidget(
                state: state,
                levelIndex: widget.levelIndex,
                bestSteps: ref.read(gameProvider.notifier).bestSteps,
                onRestart: () {
                  _resultShown = false;
                  ref.read(gameProvider.notifier).restart();
                },
                onHome: () {
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
              BoardWidget(state: state),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ControlPad(
                  onDirection: _handleDirection,
                  enabled: state.status == GameStatus.playing,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResult(GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ResultScreen(
        state: state,
        onRestart: () {
          Navigator.pop(ctx);
          _resultShown = false;
          ref.read(gameProvider.notifier).restart();
        },
        onNext: () {
          Navigator.pop(ctx);
          _resultShown = false;
          final next = widget.levelIndex + 1;
          if (next < LevelLoader.totalLevels) {
            ref.read(gameProvider.notifier).loadLevel(next);
          } else {
            Navigator.pop(context);
          }
        },
        onHome: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
      ),
    );
  }
}
