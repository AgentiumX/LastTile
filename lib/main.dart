import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'storage/save_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await SaveManager.init();
  runApp(const ProviderScope(child: LastTileApp()));
}

class LastTileApp extends StatelessWidget {
  const LastTileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Last Tile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
