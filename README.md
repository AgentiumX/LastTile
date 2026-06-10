# Last Tile

一款极简策略解谜单机手游。

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── core/
│   ├── theme/app_theme.dart  # 主题/颜色
│   ├── constants/            # 游戏常量
│   └── utils/direction.dart  # 方向枚举
├── models/
│   ├── tile.dart             # 格子类型定义
│   ├── level.dart            # 关卡
│   ├── player.dart           # 玩家状态
│   ├── game_state.dart       # 游戏全局状态
│   └── level_data.dart       # 50关手工关卡数据
├── engine/
│   ├── game_engine.dart      # 核心移动/胜负逻辑
│   ├── path_solver.dart      # A* 最优解求解
│   ├── level_generator.dart  # 程序化关卡生成
│   └── level_loader.dart     # 关卡加载
├── state/
│   └── game_provider.dart    # Riverpod 状态管理
├── screens/
│   ├── home_screen.dart      # 关卡选择界面
│   ├── level_screen.dart     # 游戏主界面
│   └── result_screen.dart    # 结算界面
├── widgets/
│   ├── tile_widget.dart      # 单格渲染
│   ├── board_widget.dart     # 棋盘渲染
│   ├── hud_widget.dart       # 顶部HUD
│   └── control_pad.dart      # 方向键
└── storage/
    └── save_manager.dart     # Hive 本地存档
```

## 运行

```bash
flutter pub get
flutter run
```

## 关卡验证

```bash
dart tool/validate_levels.dart
```

## 技术栈

- **框架**: Flutter
- **状态管理**: Riverpod
- **本地存储**: Hive
- **路径算法**: A*
