### Task 7: ConverterController（首页换算逻辑）

**Files:**
- Create: `exchange_rate/lib/controllers/converter_controller.dart`
- Test: `exchange_rate/test/controllers/converter_controller_test.dart`

**Interfaces:**
- Consumes: `RateRepository.getRates`, `ExchangeRateTable.convert`, `kDefaultBase`, `kDefaultTarget`
- Produces（GetxController，字段用 `.obs`）:
  - `final base = kDefaultBase.obs; final target = kDefaultTarget.obs;`
  - `final amount = 1.0.obs;`
  - `final Rxn<ExchangeRateTable> table;`
  - `final isLoading = false.obs; final error = RxnString();`
  - `double get result`（`table.convert(amount, base, target) ?? 0`）
  - `Future<void> load({bool forceRefresh = false})`
  - `void swap()`（交换 base/target）
  - `void setAmount(String raw)`（解析失败置 0）
  - `void setBase(String code)` / `void setTarget(String code)`

- [ ] **Step 1: 写失败测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate/controllers/converter_controller.dart';
import 'package:exchange_rate/models/exchange_rate_table.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';
import 'package:exchange_rate/core/api_client.dart';

class _StubApi extends ApiClient {
  @override
  Future<Map<String, dynamic>> getLatest(String base) async => {
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_unix':
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'rates': {'USD': 1, 'CNY': 7.26, 'EUR': 0.93},
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
  late ConverterController c;
  setUp(() {
    c = ConverterController(
      repo: RateRepository(api: _StubApi(), storage: _MemStorage()),
    );
  });

  test('load 后可换算 CNY->USD', () async {
    await c.load();
    c.setAmount('726');
    expect(c.result, closeTo(100, 0.01));
  });

  test('swap 交换 base/target', () async {
    await c.load();
    c.swap();
    expect(c.base.value, 'USD');
    expect(c.target.value, 'CNY');
  });

  test('setAmount 非法输入置 0', () async {
    await c.load();
    c.setAmount('abc');
    expect(c.amount.value, 0);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `cd exchange_rate && flutter test test/controllers/converter_controller_test.dart`
Expected: `ConverterController` 未定义。

- [ ] **Step 3: 实现 converter_controller.dart**

```dart
import 'package:get/get.dart';
import '../core/constants.dart';
import '../models/exchange_rate_table.dart';
import '../repositories/rate_repository.dart';

class ConverterController extends GetxController {
  final RateRepository repo;
  ConverterController({required this.repo});

  final base = kDefaultBase.obs;
  final target = kDefaultTarget.obs;
  final amount = 1.0.obs;
  final table = Rxn<ExchangeRateTable>();
  final isLoading = false.obs;
  final error = RxnString();

  double get result =>
      table.value?.convert(amount.value, base.value, target.value) ?? 0;

  double get unitRate =>
      table.value?.rate(base.value, target.value) ?? 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    error.value = null;
    try {
      table.value = await repo.getRates(forceRefresh: forceRefresh);
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void setAmount(String raw) {
    amount.value = double.tryParse(raw.trim()) ?? 0;
  }

  void setBase(String code) => base.value = code;
  void setTarget(String code) => target.value = code;

  void swap() {
    final b = base.value;
    base.value = target.value;
    target.value = b;
  }
}
```

- [ ] **Step 4: 运行确认通过**

Run: `cd exchange_rate && flutter test test/controllers/converter_controller_test.dart`
Expected: All tests passed!

- [ ] **Step 5: Commit**

```bash
cd exchange_rate && git add lib/controllers/converter_controller.dart test/controllers/converter_controller_test.dart && git commit -m "feat: add converter controller"
```

---


---
## 环境注意（重要）
本地用 fvm 管理 Flutter，所有命令必须加 `fvm` 前缀：`fvm flutter test`、`fvm flutter analyze`、`fvm dart ...`。不要用裸 `flutter`。
