### Task 8: RatesController（行情列表逻辑）

**Files:**
- Create: `exchange_rate/lib/controllers/rates_controller.dart`
- Test: `exchange_rate/test/controllers/rates_controller_test.dart`

**Interfaces:**
- Consumes: `RateRepository.getRates`, `ExchangeRateTable.rate`, `kDefaultCurrencies`, `currencyOf`
- Produces（GetxController）:
  - `final quote = kDefaultBase.obs;`（报价基准，默认 CNY，即列表显示 `1 单位外币 ≈ ? CNY`）
  - `final search = ''.obs;`
  - `final Rxn<ExchangeRateTable> table;`
  - `final isLoading = false.obs;`
  - `class RateRow { final Currency currency; final double rate; }`
  - `List<RateRow> get rows`（对 `kDefaultCurrencies` 中每个非 quote 币种算 `rate(code, quote)`，再按 `search` 过滤 code/cnName）
  - `Future<void> load({bool forceRefresh = false})`

- [ ] **Step 1: 写失败测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate/controllers/rates_controller.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';
import 'package:exchange_rate/core/api_client.dart';

class _StubApi extends ApiClient {
  @override
  Future<Map<String, dynamic>> getLatest(String base) async => {
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_unix':
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'rates': {'USD': 1, 'CNY': 7.26, 'EUR': 0.93, 'JPY': 157.0},
      };
}

class _MemStorage implements RateStorage {
  final Map<String, Map<String, dynamic>> box = {};
  @override
  Map<String, dynamic>? read(String key) => box[key];
  @override
  Future<void> write(String key, Map<String, dynamic> value) async =>
      box[key] = value;
}

void main() {
  late RatesController c;
  setUp(() {
    c = RatesController(
      repo: RateRepository(api: _StubApi(), storage: _MemStorage()),
    );
  });

  test('rows 生成非基准币种行且换算为 CNY', () async {
    await c.load();
    final usd = c.rows.firstWhere((r) => r.currency.code == 'USD');
    expect(usd.rate, closeTo(7.26, 0.01)); // 1 USD ≈ 7.26 CNY
    expect(c.rows.any((r) => r.currency.code == 'CNY'), isFalse);
  });

  test('search 过滤', () async {
    await c.load();
    c.search.value = 'USD';
    expect(c.rows.length, 1);
    expect(c.rows.first.currency.code, 'USD');
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `cd exchange_rate && flutter test test/controllers/rates_controller_test.dart`
Expected: `RatesController` 未定义。

- [ ] **Step 3: 实现 rates_controller.dart**

```dart
import 'package:get/get.dart';
import '../core/constants.dart';
import '../core/currency_meta.dart';
import '../models/currency.dart';
import '../models/exchange_rate_table.dart';
import '../repositories/rate_repository.dart';

class RateRow {
  final Currency currency;
  final double rate;
  RateRow(this.currency, this.rate);
}

class RatesController extends GetxController {
  final RateRepository repo;
  RatesController({required this.repo});

  final quote = kDefaultBase.obs; // CNY
  final search = ''.obs;
  final table = Rxn<ExchangeRateTable>();
  final isLoading = false.obs;

  List<RateRow> get rows {
    final t = table.value;
    if (t == null) return [];
    final q = search.value.trim().toUpperCase();
    final result = <RateRow>[];
    for (final code in kDefaultCurrencies) {
      if (code == quote.value) continue;
      final r = t.rate(code, quote.value);
      if (r == null) continue;
      final cur = currencyOf(code);
      if (q.isNotEmpty &&
          !code.contains(q) &&
          !cur.cnName.toUpperCase().contains(q)) {
        continue;
      }
      result.add(RateRow(cur, r));
    }
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    try {
      table.value = await repo.getRates(forceRefresh: forceRefresh);
    } on ApiException {
      // 静默：保留上次数据
    } finally {
      isLoading.value = false;
    }
  }
}
```

- [ ] **Step 4: 运行确认通过**

Run: `cd exchange_rate && flutter test test/controllers/rates_controller_test.dart`
Expected: All tests passed!

- [ ] **Step 5: Commit**

```bash
cd exchange_rate && git add lib/controllers/rates_controller.dart test/controllers/rates_controller_test.dart && git commit -m "feat: add rates controller with search filter"
```

---


---
## 环境说明（重要）
本机用 fvm 管理 Flutter。所有命令必须加 `fvm` 前缀：
- `fvm flutter test <path>`
- `fvm flutter analyze <path>`
- `fvm flutter pub get`
不要用裸 `flutter`/`dart`。
