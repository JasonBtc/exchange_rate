# Task 5 Report: RateRepository — fetchFresh

## Status
DONE

## Commit
- SHA: `9374d81`
- Message: `feat: add rate repository fetchFresh`

## Changed files
- `lib/repositories/rate_repository.dart` (new)
- `test/repositories/rate_repository_test.dart` (new)

Untouched (as instructed): `ios/Flutter/Debug.xcconfig`, `ios/Flutter/Release.xcconfig`, `ios/Podfile` — remain unstaged.

## TDD trace

### Step 1: Wrote failing test
Created `test/repositories/rate_repository_test.dart` verbatim from brief (with `_FakeApi extends ApiClient`, `_FakeStorage implements RateStorage`). IDE diagnostics immediately reported the expected undefined symbols.

### Step 2: Ran test — confirmed failure
Command: `fvm flutter test test/repositories/rate_repository_test.dart`

Output:
```
00:00 +0: loading /Users/jason/developer/flutter_worksapce/currency_exchange_rate/exchange_rate/test/repositories/rate_repository_test.dart
test/repositories/rate_repository_test.dart:3:8: Error: Error when reading 'lib/repositories/rate_repository.dart': No such file or directory
import 'package:exchange_rate/repositories/rate_repository.dart';
       ^
test/repositories/rate_repository_test.dart:15:31: Error: Type 'RateStorage' not found.
class _FakeStorage implements RateStorage {
                              ^^^^^^^^^^^
test/repositories/rate_repository_test.dart:27:18: Error: Method not found: 'RateRepository'.
    final repo = RateRepository(api: _FakeApi(), storage: storage);
                 ^^^^^^^^^^^^^^
00:00 +0 -1: loading .../test/repositories/rate_repository_test.dart [E]
  Failed to load ...
00:00 +0 -1: Some tests failed.
```

### Step 3: Implementation
Created `lib/repositories/rate_repository.dart` verbatim from brief:
- `abstract class RateStorage { Map<String,dynamic>? read(String); Future<void> write(String, Map<String,dynamic>); }`
- `class RateRepository({required ApiClient api, required RateStorage storage})` with `Future<ExchangeRateTable> fetchFresh()` doing `api.getLatest('USD')` -> `ExchangeRateTable.fromApi(json)` -> `storage.write(CacheKey.rateTable, table.toJson())` -> return table.

### Step 4: Ran test — confirmed pass
Command: `fvm flutter test test/repositories/rate_repository_test.dart`

Output:
```
00:00 +0: loading /Users/jason/developer/flutter_worksapce/currency_exchange_rate/exchange_rate/test/repositories/rate_repository_test.dart
00:00 +0: fetchFresh 拉取并写入缓存
00:00 +1: All tests passed!
```

### Analyze
Command: `fvm flutter analyze lib/repositories/rate_repository.dart test/repositories/rate_repository_test.dart`

Output:
```
Analyzing 2 items...

No issues found! (ran in 1.2s)
```

### Step 5: Commit
Command: `git add lib/repositories/rate_repository.dart test/repositories/rate_repository_test.dart && git commit -m "feat: add rate repository fetchFresh"`

Output:
```
[main 9374d81] feat: add rate repository fetchFresh
 2 files changed, 54 insertions(+)
 create mode 100644 lib/repositories/rate_repository.dart
 create mode 100644 test/repositories/rate_repository_test.dart
```

## Concerns
None. Brief-specified files created verbatim, no scope creep. Get_storage-backed `RateStorage` implementation is not in scope for Task 5 (fetch+parse only); it will be added in a later task per the brief.
