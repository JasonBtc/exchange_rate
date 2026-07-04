### Task 6: Repository —— 缓存优先 + 当天有效性

**Files:**
- Modify: `exchange_rate/lib/repositories/rate_repository.dart`
- Modify: `exchange_rate/test/repositories/rate_repository_test.dart`

**Interfaces:**
- Consumes: 同 Task 5，新增 `ExchangeRateTable.isFromToday`, `ExchangeRateTable.fromJson`
- Produces:
  - `Future<ExchangeRateTable> getRates({bool forceRefresh = false, DateTime? now})`：
    - 若缓存存在且 `isFromToday(now)` 且未强制刷新 → 返回缓存；
    - 否则调 `fetchFresh()`；网络失败但有旧缓存 → 返回旧缓存（离线兜底）；无缓存则 rethrow。
  - `ExchangeRateTable? cached()`：读缓存，无则 null。

- [ ] **Step 1: 追加失败测试**

在测试文件 `main()` 内追加：

```dart
  test('getRates 命中当天缓存则不请求网络', () async {
    final storage = _FakeStorage();
    // 预置今天的缓存
    final today = DateTime.now();
    storage.box['rate_table'] = {
      'base': 'USD',
      'usdRates': {'USD': 1.0, 'CNY': 7.0},
      'updatedAt': today.millisecondsSinceEpoch,
    };
    var apiCalled = false;
    final repo = RateRepository(
      api: _CountingApi(() => apiCalled = true),
      storage: storage,
    );
    final table = await repo.getRates(now: today);
    expect(apiCalled, isFalse);
    expect(table.usdRates['CNY'], 7.0);
  });

  test('getRates 缓存过期则请求网络', () async {
    final storage = _FakeStorage();
    storage.box['rate_table'] = {
      'base': 'USD',
      'usdRates': {'USD': 1.0, 'CNY': 7.0},
      'updatedAt': DateTime(2020, 1, 1).millisecondsSinceEpoch,
    };
    final repo = RateRepository(api: _FakeApi(), storage: storage);
    final table = await repo.getRates(now: DateTime.now());
    expect(table.usdRates['CNY'], 7.26); // 来自网络
  });
```

在文件顶部 fake 区追加：

```dart
class _CountingApi extends ApiClient {
  final void Function() onCall;
  _CountingApi(this.onCall);
  @override
  Future<Map<String, dynamic>> getLatest(String base) async {
    onCall();
    return {
      'result': 'success',
      'base_code': 'USD',
      'time_last_update_unix': 1751500800,
      'rates': {'USD': 1, 'CNY': 7.26},
    };
  }
}
```

- [ ] **Step 2: 运行确认失败**

Run: `cd exchange_rate && flutter test test/repositories/rate_repository_test.dart`
Expected: `getRates` 未定义。

- [ ] **Step 3: 在 rate_repository.dart 追加 getRates / cached**

在 `RateRepository` 类内 `fetchFresh` 后追加：

```dart
  ExchangeRateTable? cached() {
    final json = storage.read(CacheKey.rateTable);
    if (json == null) return null;
    return ExchangeRateTable.fromJson(json);
  }

  Future<ExchangeRateTable> getRates(
      {bool forceRefresh = false, DateTime? now}) async {
    final current = now ?? DateTime.now();
    final local = cached();
    if (!forceRefresh && local != null && local.isFromToday(current)) {
      return local;
    }
    try {
      return await fetchFresh();
    } on ApiException {
      if (local != null) return local; // 离线兜底
      rethrow;
    }
  }
```

- [ ] **Step 4: 运行确认通过**

Run: `cd exchange_rate && flutter test test/repositories/rate_repository_test.dart`
Expected: All tests passed!

- [ ] **Step 5: Commit**

```bash
cd exchange_rate && git add lib/repositories/rate_repository.dart test/repositories/rate_repository_test.dart && git commit -m "feat: add cache-first getRates with today validity and offline fallback"
```

---


## 环境说明

本地用 fvm 管理 Flutter。所有命令必须加 `fvm` 前缀：`fvm flutter test`、`fvm flutter analyze`、`fvm dart ...`。不要用裸 `flutter`。
