# Last Tile 技术设计文档（TDD）

## 文档信息

| 项目 | 内容 |
|------|------|
| 项目名称 | Last Tile |
| 版本 | v1.0 MVP |
| 技术目标 | Web / Android / iOS 三端统一 |
| 架构模式 | 前端单体应用（Offline First） |
| 开发人数 | 1~2人 |
| 预计周期 | 4~8周 |

---

## 1. 技术选型

### 推荐方案

**Flutter**

选择：Flutter

**原因：**

一套代码三端运行，支持 Web、Android、iOS。

### 游戏复杂度低

Last Tile 本质是：
- 状态机
- 网格渲染
- 动画

无需使用重型游戏引擎。

### 开发效率高

MVP阶段：Flutter > Unity

**原因：**
- UI开发快
- 包体小
- 部署简单

### 后续扩展

未来增加：
- 每日挑战
- 云同步
- 成就系统

无需重构架构。

---

## 2. 整体架构

```
Presentation Layer
        │
        ▼
Game State Layer
        │
        ▼
Game Engine Layer
        │
        ▼
Persistence Layer
```

---

## 3. 目录结构

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── utils/
│   ├── theme/
├── models/
│   ├── tile.dart
│   ├── level.dart
│   ├── player.dart
├── engine/
│   ├── game_engine.dart
│   ├── path_solver.dart
│   ├── level_generator.dart
├── state/
│   ├── game_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── level_screen.dart
│   ├── result_screen.dart
├── widgets/
│   ├── tile_widget.dart
│   ├── board_widget.dart
│   ├── hud_widget.dart
├── storage/
│   ├── save_manager.dart
```

---

## 4. 数据模型

### Tile

```dart
enum TileType {
  normal,
  bridge,
  teleport,
  key,
  lock,
  flip
}

class Tile {
  final int row;
  final int col;
  TileType type;
  bool visited;
  String? teleportId;
}
```

### Level

```dart
class Level {
  String id;
  int rows;
  int cols;
  int optimalSteps;
  int allowedSteps;
  List<Tile> tiles;
}
```

### GameState

```dart
class GameState {
  Level currentLevel;
  Point playerPosition;
  int remainingSteps;
  bool completed;
  bool failed;
}
```

---

## 5. 游戏引擎

### 核心模块：GameEngine

**职责：**
- 移动验证
- 格子销毁
- 失败判定
- 胜利判定
- 特殊格触发

### Move()

```dart
move(Direction direction)
```

**流程：**
```
点击方向
     ↓
检查边界
     ↓
检查格子存在
     ↓
移动
     ↓
销毁旧格
     ↓
触发特殊事件
     ↓
检查胜负
```

---

## 6. 状态管理

**推荐：Riverpod**

**原因：**
- Flutter主流
- 性能稳定
- 测试方便

### 状态树

```
GameProvider
├─ currentLevel
├─ playerPosition
├─ remainingSteps
├─ bestScore
└─ gameStatus
```

---

## 7. 渲染系统

### BoardWidget

**负责：** 地图渲染

**实现：** GridView.builder()

### TileWidget

**负责：** 单格绘制

**状态：**
- Normal
- Visited
- Start
- End
- Teleport
- Lock

---

## 8. 动画系统

Flutter内置 AnimatedContainer 即可。

### 格子坍塌动画

- **时长：** 150ms
- **流程：**
```
缩放100%
     ↓
    70%
     ↓
     0%
```

### 玩家移动动画

- **时长：** 200ms
- **插值：** Tween<Offset>()

### 通关动画

终点发光：500ms

---

## 9. 地图存储

MVP推荐：JSON

### 示例

```json
{
  "id": "level_001",
  "rows": 8,
  "cols": 8,
  "optimalSteps": 24,
  "allowedSteps": 28,
  "tiles": [
    {
      "row": 0,
      "col": 0,
      "type": "start"
    }
  ]
}
```

**目录：** assets/levels/

---

## 10. 本地存档

**推荐：Hive Database**

**原因：**
- Flutter原生支持
- 无需SQLite
- 性能高

### 存储内容

- 当前关卡
- 最佳成绩
- 星级记录
- 设置

### 结构

```dart
class SaveData {
  int unlockedLevel;
  Map<String,int> bestSteps;
  Map<String,int> stars;
}
```

---

## 11. 关卡生成器

### 模块：LevelGenerator

**职责：** 生成可解地图

### 流程

```
随机地图
     ↓
DFS搜索
     ↓
验证可达
     ↓
计算最优解
     ↓
保存
```

### 算法

**DFS（深度优先搜索）**

用于：存在解验证

**A\*（A Star）**

用于：最优路径计算

---

## 12. Near Miss 生成系统

这是核心。

### 目标

制造"差一点成功"体验。

### 算法

```
生成最优路径
     ↓
生成次优路径
     ↓
确保次优路径距离成功仅差1~3步
```

### 示例

```
最优: 24步
Near Miss: 26步
```

玩家会反复接近成功。

---

## 13. 评分系统

5星、4星、3星、2星、1星

**计算：** delta = playerSteps - optimalSteps

**规则：**
| delta | 星级 |
|-------|------|
| 0步 | 5星 |
| 1步 | 4星 |
| 2步 | 3星 |
| 3步 | 2星 |
| 4+步 | 1星 |

---

## 14. 音频

**推荐：** audioplayers

### 文件

- move.wav
- collapse.wav
- near_miss.wav
- victory.wav

---

## 15. 测试

### 单元测试

**覆盖：**
- Move()
- Win()
- Lose()
- Teleport()
- Key()
- Lock()

**目标：** >90%

### 自动化测试

**Flutter：** flutter test

### Web测试

- Chrome
- Safari
- Firefox
- Edge

### Mobile测试

**Android：**
- Android 10+
- Android 12+
- Android 14+

**iOS：**
- iOS 16+
- iOS 17+
- iOS 18+

---

## 16. MVP发布架构

```
Flutter
│
├── Web
│      └── Firebase Hosting
│
├── Android
│      └── Google Play
│
└── iOS
       └── App Store
```

---

## 17. 后续扩展架构

预留模块：
- achievement/
- daily_challenge/
- cloud_save/
- analytics/

未来可接入：
- Firebase
- Supabase

实现：
- 云存档
- 成就系统
- 每日谜题

---

## MVP 技术结论

对于《Last Tile》这种产品，最合适的技术栈是：

| 层级 | 技术 |
|------|------|
| UI框架 | Flutter |
| 状态管理 | Riverpod |
| 本地数据库 | Hive |
| 动画 | Flutter Animation |
| 地图格式 | JSON |
| 路径搜索 | DFS + A* |
| Web部署 | Firebase Hosting |
| Android | APK/AAB |
| iOS | IPA |

整体代码量预计：
- MVP：5,000~8,000行
- 完整版：15,000~25,000行

对于单人独立开发者，这是目前维护成本最低、跨平台兼容性最好的主流方案。
