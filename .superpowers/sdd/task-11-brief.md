### Task 11: 主题（对齐设计稿 token）

**Files:**
- Create: `exchange_rate/lib/core/app_theme.dart`

**Interfaces:**
- Produces:
  - `class AppTheme { static ThemeData get light; static ThemeData get dark; }`
  - 主色 `Color(0xFF2F6BFF)`（≈ accent oklch）、卡片圆角 20、`useMaterial3: true`、数字用 `fontFeatures: tabularFigures`。
  - 暗色背景对齐 CSS `theme-dark`（深蓝灰）。

- [ ] **Step 1: 实现 app_theme.dart**

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color accent = Color(0xFF2F6BFF);
  static const Color positive = Color(0xFF1FB980);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF16181F),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF23262F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}
```

- [ ] **Step 2: 验证编译**

Run: `cd exchange_rate && flutter analyze lib/core/app_theme.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd exchange_rate && git add lib/core/app_theme.dart && git commit -m "feat: add light/dark theme aligned with design tokens"
```

---



---
**环境提示**：本机用 fvm 管理 Flutter。所有命令加 `fvm` 前缀：`fvm flutter test`、`fvm flutter analyze`。
**重要**：真正写文件并提交，提交后用 `git log --oneline -1` 确认 HEAD 就是你的提交，报告里回报真实的 commit hash。
