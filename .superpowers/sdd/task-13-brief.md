### Task 13: ConverterPage 换算首页 + 币种选择器

**Files:**
- Create: `exchange_rate/lib/views/converter/converter_page.dart`
- Create: `exchange_rate/lib/views/converter/widgets/currency_picker.dart`
- Modify: `exchange_rate/lib/views/home/home_page.dart`（替换占位页）
- Test: `exchange_rate/test/views/converter_page_test.dart`

**Interfaces:**
- Consumes: `ConverterController`(Get.find), `currencyOf`, `kDefaultCurrencies`, `SettingsController.decimals`
- Produces:
  - `class ConverterPage extends StatelessWidget`
  - `Future<String?> showCurrencyPicker(BuildContext, {required String selected})`（底部弹窗返回选中 code）
  - 页面结构对齐 iOS converter 设计：深色换算卡（输入金额 + base chip / 结果 + target chip）、swap 按钮、常用币种 segmented、汇率说明。

- [ ] **Step 1: 写 widget 失败测试**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:exchange_rate/controllers/converter_controller.dart';
import 'package:exchange_rate/controllers/settings_controller.dart';
import 'package:exchange_rate/models/exchange_rate_table.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';
import 'package:exchange_rate/core/api_client.dart';
import 'package:exchange_rate/views/converter/converter_page.dart';

class _StubApi extends ApiClient {
  @override
  Future<Map<String, dynamic>> getLatest(String base) async => {
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_unix':
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'rates': {'USD': 1, 'CNY': 7.26},
      };
}

class _Mem implements RateStorage {
  final box = <String, Map<String, dynamic>>{};
  @override
  Map<String, dynamic>? read(String k) => box[k];
  @override
  Future<void> write(String k, Map<String, dynamic> v) async => box[k] = v;
}

void main() {
  testWidgets('显示结果数值', (tester) async {
    final repo = RateRepository(api: _StubApi(), storage: _Mem());
    Get.put(SettingsController());
    final c = Get.put(ConverterController(repo: repo));
    await c.load();
    c.setAmount('726');

    await tester.pumpWidget(const GetMaterialApp(home: ConverterPage()));
    await tester.pump();

    expect(find.textContaining('100'), findsWidgets); // 726 CNY ≈ 100 USD
    Get.reset();
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `cd exchange_rate && flutter test test/views/converter_page_test.dart`
Expected: `ConverterPage` 未定义。

- [ ] **Step 3: 实现 currency_picker.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/currency_meta.dart';

Future<String?> showCurrencyPicker(
  BuildContext context, {
  required String selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => ListView(
      shrinkWrap: true,
      children: kDefaultCurrencies.map((code) {
        final cur = currencyOf(code);
        return ListTile(
          leading: Text(cur.flag, style: const TextStyle(fontSize: 24)),
          title: Text('${cur.cnName} $code'),
          trailing: code == selected
              ? const Icon(Icons.check, color: Color(0xFF2F6BFF))
              : null,
          onTap: () => Navigator.pop(ctx, code),
        );
      }).toList(),
    ),
  );
}
```

- [ ] **Step 4: 实现 converter_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/converter_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/currency_meta.dart';
import 'widgets/currency_picker.dart';

class ConverterPage extends StatelessWidget {
  const ConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ConverterController>();
    final settings = Get.find<SettingsController>();
    final amountCtrl = TextEditingController(
        text: c.amount.value == 0 ? '' : c.amount.value.toString());

    return Scaffold(
      appBar: AppBar(title: const Text('实时换算')),
      body: RefreshIndicator(
        onRefresh: () => c.load(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Obx(() {
              final baseCur = currencyOf(c.base.value);
              final targetCur = currencyOf(c.target.value);
              final dec = settings.decimals.value;
              return Card(
                color: const Color(0xFF1B1E27),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('输入金额',
                          style: TextStyle(color: Colors.white70)),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: amountCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              onChanged: c.setAmount,
                            ),
                          ),
                          _chip(context, '${baseCur.flag} ${baseCur.code}',
                              () async {
                            final r = await showCurrencyPicker(context,
                                selected: c.base.value);
                            if (r != null) c.setBase(r);
                          }),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 32),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('换算为 ${targetCur.code}',
                                  style: const TextStyle(
                                      color: Colors.white70)),
                              Text(
                                c.result.toStringAsFixed(dec),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          _chip(context,
                              '${targetCur.flag} ${targetCur.code}',
                              () async {
                            final r = await showCurrencyPicker(context,
                                selected: c.target.value);
                            if (r != null) c.setTarget(r);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: c.swap,
                icon: const Icon(Icons.swap_vert),
                label: const Text('交换币种'),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => c.error.value == null
                ? const SizedBox.shrink()
                : Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('数据加载失败：${c.error.value}',
                          style: TextStyle(color: Colors.red.shade700)),
                    ),
                  )),
            Obx(() {
              final r = c.unitRate;
              return Card(
                child: ListTile(
                  title: Text(
                      '1 ${c.base.value} ≈ ${r.toStringAsFixed(4)} ${c.target.value}'),
                  subtitle: Text(c.table.value == null
                      ? '加载中…'
                      : '更新时间 ${c.table.value!.updatedAt}'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.white24,
      onPressed: onTap,
    );
  }
}
```

- [ ] **Step 5: 在 home_page.dart 引入真实页面**

替换 `_pages` 列表第一项与 import：

```dart
import 'package:flutter/material.dart';
import '../converter/converter_page.dart';
// Task 14/15 完成后再补 rates/settings import

// _pages 改为：
  final _pages = const [
    ConverterPage(),
    Center(child: Text('行情')),
    Center(child: Text('设置')),
  ];
```

- [ ] **Step 6: 运行确认通过**

Run: `cd exchange_rate && flutter test test/views/converter_page_test.dart`
Expected: All tests passed!

- [ ] **Step 7: Commit**

```bash
cd exchange_rate && git add lib/views/converter lib/views/home/home_page.dart test/views/converter_page_test.dart && git commit -m "feat: add converter page with currency picker"
```

---

