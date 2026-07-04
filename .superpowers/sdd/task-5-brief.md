### Task 5: Repository —— 拉取与解析

**Files:**
- Create: `exchange_rate/lib/repositories/rate_repository.dart`
- Test: `exchange_rate/test/repositories/rate_repository_test.dart`

**Interfaces:**
- Consumes: `ApiClient.getLatest`, `ExchangeRateTable.fromApi`, `CacheKey.rateTable`
- Produces:
  - `abstract class RateStorage { Map<String,dynamic>? read(String key); Future<void> write(String key, Map<String,dynamic> value); }`（便于测试注入，生产用 get_storage 实现）
  - `class RateRepository { RateRepository({required ApiClient api, required RateStorage storage}); Future<ExchangeRateTable> fetchFresh(); }`
  - `fetchFresh()`：请求 USD 基准 → 解析 → 写缓存 → 返回。

- [ ] **Step 1: 写失败测试（用 fake api + fake storage）**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate/core/api_client.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';

class _FakeApi extends ApiClient {
  @override
  Future<Map<String, dynamic>> getLatest(String base) async => {
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_unix': 1751500800,
        'rates': {'USD': 1, 'CNY': 7.26, 'EUR': 0.93},
      };
}

class _FakeStorage implements RateStorage {
  final Map<String, Map<String, dynamic>> box = {};
  @override
  Map<String, dynamic>? read(String key) => box[key];
  @override
  Future<void> write(String key, Map<String, dynamic> value) async =>
      box[key] = value;
}

void main() {
  test('fetchFresh 拉取并写入缓存', () async {
    final storage = _FakeStorage();
    final repo = RateRepository(api: _FakeApi(), storage: storage);
    final table = await repo.fetchFresh();
    expect(table.usdRates['CNY'], 7.26);
    expect(storage.box.containsKey('rate_table'), isTrue);
  });
}
```

- [ ] **Step 2: 运行确认失败**

Run: `cd exchange_rate && flutter test test/repositories/rate_repository_test.dart`
Expected: `RateRepository` / `RateStorage` 未定义。

- [ ] **Step 3: 实现 rate_repository.dart（仅 fetchFresh）**

```dart
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/exchange_rate_table.dart';

abstract class RateStorage {
  Map<String, dynamic>? read(String key);
  Future<void> write(String key, Map<String, dynamic> value);
}

class RateRepository {
  final ApiClient api;
  final RateStorage storage;

  RateRepository({required this.api, required this.storage});

  Future<ExchangeRateTable> fetchFresh() async {
    final json = await api.getLatest('USD');
    final table = ExchangeRateTable.fromApi(json);
    await storage.write(CacheKey.rateTable, table.toJson());
    return table;
  }
}
```

- [ ] **Step 4: 运行确认通过**

Run: `cd exchange_rate && flutter test test/repositories/rate_repository_test.dart`
Expected: All tests passed!

- [ ] **Step 5: Commit**

```bash
cd exchange_rate && git add lib/repositories/rate_repository.dart test/repositories/rate_repository_test.dart && git commit -m "feat: add rate repository fetchFresh"
```

---



---
## 环境注意
本地用 fvm 管理 Flutter。所有命令加 fvm 前缀：`fvm flutter test ...`、`fvm flutter analyze ...`、`fvm dart ...`。
