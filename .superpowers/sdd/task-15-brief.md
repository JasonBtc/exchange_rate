### Task 15: SettingsPage 设置页

**Files:**
- Create: `exchange_rate/lib/views/settings/settings_page.dart`
- Modify: `exchange_rate/lib/views/home/home_page.dart`

**Interfaces:**
- Consumes: `SettingsController`(Get.find)
- Produces: `class SettingsPage extends StatelessWidget`，深色主题开关（`SwitchListTile`）+ 换算精度 segmented（2/4/6）+ 关于信息。

- [ ] **Step 1: 实现 settings_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          Obx(() => SwitchListTile(
                title: const Text('深色主题'),
                subtitle: const Text('适合夜间查价'),
                value: c.isDark.value,
                onChanged: c.toggleTheme,
              )),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('换算精度'),
          ),
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 2, label: Text('2 位')),
                    ButtonSegment(value: 4, label: Text('4 位')),
                    ButtonSegment(value: 6, label: Text('6 位')),
                  ],
                  selected: {c.decimals.value},
                  onSelectionChanged: (s) => c.setDecimals(s.first),
                ),
              )),
          const Divider(),
          const ListTile(
            title: Text('数据来源'),
            subtitle: Text('open.er-api.com · 每日更新'),
          ),
          const AboutListTile(
            applicationName: '汇率换算',
            applicationVersion: '1.0.0',
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: home_page.dart 引入真实页面**

```dart
import '../settings/settings_page.dart';
// _pages 第三项改为 SettingsPage()
// 此时三项均为真实页面，移除 const（因 SettingsPage/RatesPage 构造允许 const，可保留 const 列表）
```

- [ ] **Step 3: 验证编译**

Run: `cd exchange_rate && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
cd exchange_rate && git add lib/views/settings lib/views/home/home_page.dart && git commit -m "feat: add settings page with theme and precision"
```

---


---
**环境提示（重要）**：本机用 fvm 管理 Flutter，所有命令必须加 `fvm` 前缀：`fvm flutter analyze`、`fvm flutter test`、`fvm dart ...`。裸 flutter 可能指向错误版本。

**报告落地要求（重要）**：完成后必须真实执行 `git commit`，并用 `git log -1 --oneline` 验证 commit 已落地，回报真实 commit hash（前面有 Task 曾谎报提交但未落地，务必先 git log 确认）。

**跨任务上下文**：
- `SettingsController` 构造签名 `SettingsController({SettingsStorage? storage})`；页面里用 `Get.find<SettingsController>()` 获取。已注册为 permanent（Task 12 binding）。
- 可用的响应式字段：`isDark`(RxBool)、`decimals`(RxInt=2/4/6)；方法：`toggleTheme(bool)`、`setDecimals(int)`。
- 需替换 `HomePage._pages` 里第三个占位 `Center(child: Text('设置'))` 为 `SettingsPage()`，并在 `home_page_test.dart` 里已注入 SettingsController（Task 12/13 已注入，无需重复）。
- widget 测试需 `Get.testMode = true` + `Get.put(SettingsController(storage: <内存实现>))`，避免 GetStorage 真实磁盘/定时器泄漏。
