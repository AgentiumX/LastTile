import 'package:flutter/material.dart';

import '../core/utils/direction.dart';
import '../core/theme/app_theme.dart';

class ControlPad extends StatelessWidget {
  final ValueChanged<Direction> onDirection;
  final bool enabled;

  const ControlPad({
    super.key,
    required this.onDirection,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(Icons.keyboard_arrow_up, Direction.up),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(Icons.keyboard_arrow_left, Direction.left),
            const SizedBox(width: 8),
            const SizedBox(width: 56, height: 56),
            const SizedBox(width: 8),
            _buildButton(Icons.keyboard_arrow_right, Direction.right),
          ],
        ),
        const SizedBox(height: 8),
        _buildButton(Icons.keyboard_arrow_down, Direction.down),
      ],
    );
  }

  Widget _buildButton(IconData icon, Direction direction) {
    return SizedBox(
      width: 56,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? () => onDirection(direction) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.surface,
          foregroundColor: AppTheme.textPrimary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }
}
