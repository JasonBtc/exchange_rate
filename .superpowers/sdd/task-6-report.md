# Task 6 Report: Repository —— 缓存优先 + 当天有效性

## Status
DONE

## Commit
- SHA: `37f16ae3199fe5ed9ad6a5a056e307eba3a2465c`
- Message: `feat: add cache-first getRates with today validity and offline fallback`
- Files changed:
  - `lib/repositories/rate_repository.dart` (+21 lines)
  - `test/repositories/rate_repository_test.dart` (+46 lines)

## TDD Cycle

### Step 1 — 追加失败测试
在 `test/repositories/rate_repository_test.dart` 顶部 fake 区追加了 `_CountingApi`（用于验证是否发起网络请求），在 `main()` 内追加两条测试：
- `getRates 命中当天缓存则不请求网络`
- `getRates 缓存过期则请求网络`

### Step 2 — 运行确认失败（编译错误）
命令：`fvm flutter test test/repositories/rate_repository_test.dart`

输出（截取关键部分）：
```
test/repositories/rate_repository_test.dart:62:30: Error: The method 'getRates' isn't defined for the type 'RateRepository'.
    final table = await repo.getRates(now: today);
                             ^^^^^^^^
test/repositories/rate_repository_test.dart:75:30: Error: The method 'getRates' isn't defined for the type 'RateRepository'.
    final table = await repo.getRates(now: DateTime.now());
                             ^^^^^^^^
00:00 +0 -1: Some tests failed.
```

符合预期：`getRates` 未定义。

### Step 3 — 在 `rate_repository.dart` 追加 `getRates` / `cached`
按 brief 逐字采用的实现：

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

### Step 4 — 运行确认通过
命令：`fvm flutter test test/repositories/rate_repository_test.dart`

真实输出：
```
00:00 +0: loading /Users/jason/developer/flutter_worksapce/currency_exchange_rate/exchange_rate/test/repositories/rate_repository_test.dart
00:00 +0: fetchFresh 拉取并写入缓存
00:00 +1: getRates 命中当天缓存则不请求网络
00:00 +2: getRates 缓存过期则请求网络
00:00 +3: All tests passed!
```

3/3 通过。

### 静态分析
命令：`fvm flutter analyze`

真实输出：
```
Analyzing exchange_rate...
No issues found! (ran in 1.4s)
```

### Step 5 — Commit
命令：
```
git add lib/repositories/rate_repository.dart test/repositories/rate_repository_test.dart
git commit -m "feat: add cache-first getRates with today validity and offline fallback"
```

输出：
```
[main 37f16ae] feat: add cache-first getRates with today validity and offline fallback
 2 files changed, 67 insertions(+)
```

## 未 stage 的既存文件
按上级代理约定，未处理这些既存改动（不属于本 Task 范围）：
- `ios/Flutter/Debug.xcconfig`（modified）
- `ios/Flutter/Release.xcconfig`（modified）
- `ios/Podfile`（untracked）

## Concerns
无。所有测试通过、analyze 无告警、commit 只包含 brief 指定的两个文件。
