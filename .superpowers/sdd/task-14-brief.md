### Task 14: RatesPage 行情列表页

**Files:**
- Create: `exchange_rate/lib/views/rates/rates_page.dart`
- Modify: `exchange_rate/lib/views/home/home_page.dart`

**Interfaces:**
- Consumes: `RatesController`(Get.find), `RateRow`, `currencyOf`
- Produces: `class RatesPage extends StatelessWidget`，搜索框 + Obx 列表（每行显示旗+币种名+`1 CODE ≈ x CNY`）+ 下拉刷新 + 空状态。

- [ ] **Step 1: 实现 rates_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/rates_controller.dart';

class RatesPage extends StatelessWidget {
  const RatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RatesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('行情')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '搜索币种名称或代码',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => c.search.value = v,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => c.load(forceRefresh: true),
              child: Obx(() {
                final rows = c.rows;
                if (c.isLoading.value && rows.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (rows.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('没有匹配的币种')),
                    ],
                  );
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final row = rows[i];
                    return ListTile(
                      leading: Text(row.currency.flag,
                          style: const TextStyle(fontSize: 26)),
                      title: Text(
                          '${row.currency.cnName} ${row.currency.code}'),
                      subtitle: Text(
                          '1 ${row.currency.code} ≈ ${row.rate.toStringAsFixed(4)} ${c.quote.value}'),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: home_page.dart 引入真实页面**

```dart
import '../rates/rates_page.dart';
// _pages 第二项改为 RatesPage()
```

- [ ] **Step 3: 验证编译**

Run: `cd exchange_rate && flutter analyze lib/views/rates lib/views/home`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
cd exchange_rate && git add lib/views/rates lib/views/home/home_page.dart && git commit -m "feat: add rates list page with search and pull-to-refresh"
```

---



---
**环境提示（重要）**：本机用 fvm 管理 Flutter，所有命令必须加 `fvm` 前缀：`fvm flutter analyze`、`fvm flutter test`、`fvm dart ...`。裸 flutter 可能指向错误版本。

**报告落地要求（重要）**：完成后必须真实执行 `git commit`，然后用 `git log -1 --oneline` 验证 commit 已落地，回报真实 commit hash（此前有 Task 谎报提交但未落地，务必先 git log 确认）。

**跨任务上下文**：
- `RatesController` 构造签名为 `({required RateRepository repo})`；行数据通过 `rows` getter（`List<RateRow>`，`RateRow(Currency currency, double rate)`），搜索用 `search` 这个 RxString，加载用 `load()`。
- 需替换 `lib/views/home/home_page.dart` 中第二个占位页（'行情'）为真实的 `RatesPage`。替换后 `test/views/home/home_page_test.dart` 已注入 ConverterController/SettingsController，还需为 RatesController 补注入（in-memory stub），保持 widget test 绿。
- widget test 里用 `Get.testMode = true` + in-memory `RateStorage`/`SettingsStorage` stub，避免 GetStorage 定时器泄漏。
