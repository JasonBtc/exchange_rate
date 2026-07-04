# Task 7 Report: ConverterController

## Status
DONE

## Commit
- SHA: `230a3ed73f1939993093432a9a853ebd64a8edd4`
- Message: `feat: add converter controller`
- Files changed (2, +106 lines):
  - `lib/controllers/converter_controller.dart` (new)
  - `test/controllers/converter_controller_test.dart` (new)

## Test Summary
All 3 new ConverterController tests pass; full suite 25/25 green; analyze clean.

## TDD Flow (as executed)

### Step 1: Write failing test
Created `test/controllers/converter_controller_test.dart` with the three test cases from the brief (load+convert CNY->USD ~100, swap base/target, setAmount('abc') -> 0). Used `_StubApi extends ApiClient` and `_MemStorage implements RateStorage` to isolate from network / disk.

Note vs. brief: the brief's snippet imports `models/exchange_rate_table.dart` but never references the symbol. I omitted the unused import to keep analyze clean; behavior is identical.

### Step 2: Run to confirm red
Command: `fvm flutter test test/controllers/converter_controller_test.dart`
Output:
```
test/controllers/converter_controller_test.dart:2:8: Error: Error when reading 'lib/controllers/converter_controller.dart': No such file or directory
test/controllers/converter_controller_test.dart:27:8: Error: 'ConverterController' isn't a type.
test/controllers/converter_controller_test.dart:29:9: Error: Method not found: 'ConverterController'.
00:00 +0 -1: Some tests failed.
```
Confirmed expected failure (ConverterController undefined).

### Step 3: Implement
Created `lib/controllers/converter_controller.dart` exactly per brief:
- `GetxController` with constructor-injected `RateRepository repo`
- Rx fields: `base` (`kDefaultBase.obs`), `target` (`kDefaultTarget.obs`), `amount` (`1.0.obs`), `table` (`Rxn<ExchangeRateTable>`), `isLoading` (`false.obs`), `error` (`RxnString()`)
- `double get result` -> `table.value?.convert(amount.value, base.value, target.value) ?? 0`
- `double get unitRate` -> `table.value?.rate(base.value, target.value) ?? 0`
- `onInit()` calls `load()`
- `Future<void> load({bool forceRefresh = false})` sets `isLoading`, catches `ApiException` into `error`
- `setAmount(String raw)` uses `double.tryParse(raw.trim()) ?? 0`
- `setBase` / `setTarget` setters
- `swap()` swaps base and target

No `Dio`, no direct network. Only `RateRepository` + `ApiException` from core.

### Step 4: Run to confirm green
Command: `fvm flutter test test/controllers/converter_controller_test.dart`
Output:
```
00:00 +0: loading .../converter_controller_test.dart
00:00 +0: load 后可换算 CNY->USD
00:00 +1: swap 交换 base/target
00:00 +2: setAmount 非法输入置 0
00:00 +3: All tests passed!
```

Analyze check:
Command: `fvm flutter analyze lib/controllers test/controllers`
Output:
```
Analyzing 2 items...
No issues found! (ran in 1.4s)
```

Full test suite check:
Command: `fvm flutter test`
Output tail: `00:00 +25: All tests passed!`

### Step 5: Commit
Command:
```
git add lib/controllers/converter_controller.dart test/controllers/converter_controller_test.dart
git commit -m "feat: add converter controller"
```
Output:
```
[main 230a3ed] feat: add converter controller
 2 files changed, 106 insertions(+)
 create mode 100644 lib/controllers/converter_controller.dart
 create mode 100644 test/controllers/converter_controller_test.dart
```

Only the two new files were staged. The pre-existing untracked/modified ios/ items (Debug.xcconfig, Release.xcconfig, ios/Podfile) were left as-is per instructions.

## Verified Behavior
- Load path: `_StubApi.getLatest('USD')` returns fixture with rates `{USD:1, CNY:7.26, EUR:0.93}`; `RateRepository.fetchFresh()` builds the table and caches it; `ConverterController.load()` assigns it to `table.value`.
- Conversion: with default base=CNY, target=USD, amount=726, `result` = 726 * (1/7.26) ≈ 100.0 -> passes `closeTo(100, 0.01)`.
- Swap: after swap, base=USD, target=CNY.
- Invalid input: `setAmount('abc')` -> `amount.value == 0`.

## Constraint Compliance
- Architecture: MVC. Controller only holds business logic; no widget code.
- State: GetX (`GetxController`, `.obs`, `Rxn`, `RxnString`). No Provider/Riverpod/Bloc.
- Networking: no `Dio` in controller; only `RateRepository` via constructor injection.
- Testability: repository is constructor-injected; tests use fake `ApiClient` subclass + in-memory `RateStorage`. No real network.
- Direction: default CNY -> USD, any-to-any via `setBase`/`setTarget`/`swap`.
- fvm: all commands used `fvm flutter ...`.

## Concerns
None.
