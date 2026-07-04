### Task 10: HomePage 底部导航壳

**Files:**
- Create: `exchange_rate/lib/views/home/home_page.dart`

**Interfaces:**
- Consumes: `ConverterPage`(Task 13), `RatesPage`(Task 14), `SettingsPage`(Task 15)
- Produces: `class HomePage extends StatefulWidget`，`IndexedStack` + `NavigationBar` 三 tab（换算/行情/设置）。

> 注意：本 Task 先用占位页保证可运行，Task 13-15 完成后 import 替换为真实页面。

- [ ] **Step 1: 实现 home_page.dart（占位页版本）**

```dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  // Task 13-15 完成后替换为 ConverterPage/RatesPage/SettingsPage
  final _pages = const [
    Center(child: Text('换算')),
    Center(child: Text('行情')),
    Center(child: Text('设置')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.swap_horiz), label: '换算'),
          NavigationDestination(
              icon: Icon(Icons.list_alt), label: '行情'),
          NavigationDestination(
              icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 验证编译**

Run: `cd exchange_rate && flutter analyze lib/views/home/home_page.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd exchange_rate && git add lib/views/home/home_page.dart && git commit -m "feat: add home shell with bottom navigation"
```

---



---
**环境提示**：本地用 fvm 管理 Flutter，所有命令加 `fvm` 前缀（`fvm flutter test`、`fvm flutter analyze`、`fvm flutter pub get`）。
