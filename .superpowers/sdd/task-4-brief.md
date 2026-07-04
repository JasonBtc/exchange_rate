### Task 4: 汇率表模型与交叉汇率计算

**Files:**
- Create: `exchange_rate/lib/models/exchange_rate_table.dart`
- Test: `exchange_rate/test/models/exchange_rate_table_test.dart`

**Interfaces:**
- Produces:
  - `class ExchangeRateTable { final String base; final Map<String,double> usdRates; final DateTime updatedAt; }`
  - `factory ExchangeRateTable.fromApi(Map<String,dynamic> json)`（解析 `rates` 与 `time_last_update_unix`）
  - `double? rate(String from, String to)`（交叉汇率：`usdRates[to]! / usdRates[from]!`；缺失返回 null）
  - `double? convert(double amount, String from, String to)`
  - `Map<String,dynamic> toJson()` / `factory ExchangeRateTable.fromJson(Map<String,dynamic>)`（用于缓存）
  - `bool isFromToday(DateTime now)`（`updatedAt` 与 now 同一天）

- [ ] **Step 1: 写失败测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate/models/exchange_rate_table.dart';

void main() {
  final table = ExchangeRateTable(
    base: 'USD',
    usdRates: {'USD': 1.0, 'CNY': 7.26, 'EUR': 0.933},
    updatedAt: DateTime(2026, 7, 3, 10),
  );

  test('rate 计算交叉汇率 CNY->USD', () {
    expect(table.rate('CNY', 'USD'), closeTo(1 / 7.26, 1e-6));
  });

  test('rate USD->CNY 等于牌价', () {
    expect(table.rate('USD', 'CNY'), closeTo(7.26, 1e-6));
  });

  test('convert 金额换算', () {
    expect(table.convert(100, 'CNY', 'USD'), closeTo(100 / 7.26, 1e-6));
  });

  test('未知币种返回 null', () {
    expect(table.rate('CNY', 'XXX'), isNull);
  });

  test('fromApi 解析 rates 与时间', () {
    final t = ExchangeRateTable.fromApi({
      'result': 'success',
      'base_code': 'USD',
      'time_last_update_unix': 1751500800,
      'rates': {'USD': 1, 'CNY': 7.26},
    });
    expect(t.base, 'USD');
    expect(t.usdRates['CNY'], 7.26);
  });

  test('toJson/fromJson 往返一致', () {
    final j = table.toJson();
    final back = ExchangeRateTable.fromJson(j);
    expect(back.usdRates['CNY'], 7.26);
    expect(back.updatedAt, table.updatedAt);
  });

  test('isFromToday 同天判断', () {
    expect(table.isFromToday(DateTime(2026, 7, 3, 23)), isTrue);
    expect(table.isFromToday(DateTime(2026, 7, 4, 1)), isFalse);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `cd exchange_rate && flutter test test/models/exchange_rate_table_test.dart`
Expected: 编译失败 / `ExchangeRateTable` 未定义。

- [ ] **Step 3: 实现 exchange_rate_table.dart**

```dart
class ExchangeRateTable {
  final String base; // 通常 'USD'
  final Map<String, double> usdRates;
  final DateTime updatedAt;

  ExchangeRateTable({
    required this.base,
    required this.usdRates,
    required this.updatedAt,
  });

  factory ExchangeRateTable.fromApi(Map<String, dynamic> json) {
    final rawRates = (json['rates'] as Map).map(
      (k, v) => MapEntry(k as String, (v as num).toDouble()),
    );
    final unix = (json['time_last_update_unix'] as num?)?.toInt();
    return ExchangeRateTable(
      base: json['base_code'] as String? ?? 'USD',
      usdRates: rawRates,
      updatedAt: unix != null
          ? DateTime.fromMillisecondsSinceEpoch(unix * 1000)
          : DateTime.now(),
    );
  }

  double? rate(String from, String to) {
    final rf = usdRates[from];
    final rt = usdRates[to];
    if (rf == null || rt == null || rf == 0) return null;
    return rt / rf;
  }

  double? convert(double amount, String from, String to) {
    final r = rate(from, to);
    return r == null ? null : amount * r;
  }

  bool isFromToday(DateTime now) =>
      updatedAt.year == now.year &&
      updatedAt.month == now.month &&
      updatedAt.day == now.day;

  Map<String, dynamic> toJson() => {
        'base': base,
        'usdRates': usdRates,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory ExchangeRateTable.fromJson(Map<String, dynamic> json) {
    final rates = (json['usdRates'] as Map).map(
      (k, v) => MapEntry(k as String, (v as num).toDouble()),
    );
    return ExchangeRateTable(
      base: json['base'] as String,
      usdRates: rates,
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }
}
```

- [ ] **Step 4: 运行确认通过**

Run: `cd exchange_rate && flutter test test/models/exchange_rate_table_test.dart`
Expected: All tests passed!

- [ ] **Step 5: Commit**

```bash
cd exchange_rate && git add lib/models/exchange_rate_table.dart test/models/exchange_rate_table_test.dart && git commit -m "feat: add exchange rate table with cross-rate calculation"
```

---


---
## 环境注意（重要）
本机用 fvm 管理 Flutter。所有 flutter/dart 命令必须加 `fvm` 前缀：
- 跑测试：`fvm flutter test test/models/exchange_rate_table_test.dart`
- 静态分析：`fvm flutter analyze lib/models`
不要用裸 `flutter`。
