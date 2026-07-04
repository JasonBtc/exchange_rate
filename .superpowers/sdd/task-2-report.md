# Task 2 Report: 币种模型 + 元数据 + 常量

## Status
DONE

## Commit
- `b1d671908b6af130b3513b31383d94e23d8a66ed` — feat: add currency model and metadata

## Changes
- `lib/core/constants.dart` (new): `ApiConst` (`base`, `timeout`), `CacheKey` (`rateTable`, `themeMode`, `decimals`), `kDefaultBase`, `kDefaultTarget`, `kDefaultCurrencies`.
- `lib/models/currency.dart` (new): `Currency` value class with `code` / `cnName` / `symbol` / `flag`; `==` / `hashCode` keyed on `code` only.
- `lib/core/currency_meta.dart` (new): `kCurrencyMeta` map for the 10 default codes (CNY, USD, EUR, JPY, GBP, AUD, KRW, HKD, CAD, SGD) plus `currencyOf(code)` with a code-only fallback (`🏳️`).
- `test/currency_meta_test.dart` (new): 11 unit tests covering the class shape, equality-by-code, meta coverage / non-empty fields, `CNY` exact match, `currencyOf` hit & fallback, and every constant.

All four files match the brief verbatim (field names, values, meta contents, constant strings).

## Commands and Real Output

### Step 1 — Write failing tests, then `flutter test test/currency_meta_test.dart`
```
test/currency_meta_test.dart:23:17: Error: Method not found: 'Currency'.
      const a = Currency(code: 'USD', cnName: '美元', symbol: r'$', flag: '🇺🇸');
                ^^^^^^^^
test/currency_meta_test.dart:24:17: Error: Method not found: 'Currency'.
      const b = Currency(code: 'USD', cnName: 'X', symbol: 'Y', flag: 'Z');
                ^^^^^^^^
test/currency_meta_test.dart:25:17: Error: Method not found: 'Currency'.
      const c = Currency(code: 'EUR', cnName: '欧元', symbol: '€', flag: '🇪🇺');
                ^^^^^^^^
test/currency_meta_test.dart:35:26: Error: Undefined name 'kDefaultCurrencies'.
      for (final code in kDefaultCurrencies) {
                         ^^^^^^^^^^^^^^^^^^
test/currency_meta_test.dart:36:16: Error: Undefined name 'kCurrencyMeta'.
        expect(kCurrencyMeta.containsKey(code), isTrue,
               ^^^^^^^^^^^^^
test/currency_meta_test.dart:38:16: Error: Undefined name 'kCurrencyMeta'.
        expect(kCurrencyMeta[code]!.code, code);
               ^^^^^^^^^^^^^
test/currency_meta_test.dart:43:27: Error: Undefined name 'kCurrencyMeta'.
      for (final entry in kCurrencyMeta.entries) {
                          ^^^^^^^^^^^^^
test/currency_meta_test.dart:52:19: Error: Undefined name 'kCurrencyMeta'.
      final cny = kCurrencyMeta['CNY']!;
                  ^^^^^^^^^^^^^
test/currency_meta_test.dart:62:19: Error: Method not found: 'currencyOf'.
      final usd = currencyOf('USD');
                  ^^^^^^^^^^
test/currency_meta_test.dart:65:24: Error: Undefined name 'kCurrencyMeta'.
      expect(usd, same(kCurrencyMeta['USD']));
                       ^^^^^^^^^^^^^
test/currency_meta_test.dart:69:19: Error: Method not found: 'currencyOf'.
      final xyz = currencyOf('XYZ');
                  ^^^^^^^^^^
test/currency_meta_test.dart:79:14: Error: Undefined name 'ApiConst'.
      expect(ApiConst.base, 'https://open.er-api.com/v6/latest');
             ^^^^^^^^
test/currency_meta_test.dart:80:14: Error: Undefined name 'ApiConst'.
      expect(ApiConst.timeout, const Duration(seconds: 15));
             ^^^^^^^^
test/currency_meta_test.dart:84:14: Error: Undefined name 'CacheKey'.
      expect(CacheKey.rateTable, 'rate_table');
             ^^^^^^^^
test/currency_meta_test.dart:85:14: Error: Undefined name 'CacheKey'.
      expect(CacheKey.themeMode, 'theme_mode');
             ^^^^^^^^
test/currency_meta_test.dart:86:14: Error: Undefined name 'CacheKey'.
      expect(CacheKey.decimals, 'decimals');
             ^^^^^^^^
test/currency_meta_test.dart:90:14: Error: Undefined name 'kDefaultBase'.
      expect(kDefaultBase, 'CNY');
             ^^^^^^^^^^^^
test/currency_meta_test.dart:91:14: Error: Undefined name 'kDefaultTarget'.
      expect(kDefaultTarget, 'USD');
             ^^^^^^^^^^^^^^
test/currency_meta_test.dart:95:14: Error: Undefined name 'kDefaultCurrencies'.
      expect(kDefaultCurrencies, const [
             ^^^^^^^^^^^^^^^^^^
00:00 +0 -1: Some tests failed.
```
Confirms the TDD failing-first step: the tests compile-fail because the model, meta, and constants do not yet exist.

### Step 2 — After implementing `lib/models/currency.dart`, `lib/core/currency_meta.dart`, `lib/core/constants.dart`; `flutter test test/currency_meta_test.dart`
```
00:00 +0: loading /Users/jason/developer/flutter_worksapce/currency_exchange_rate/exchange_rate/test/currency_meta_test.dart
00:00 +0: Currency holds the four required fields
00:00 +1: Currency equality and hashCode are based on code only
00:00 +2: kCurrencyMeta contains every default currency
00:00 +3: kCurrencyMeta entries have non-empty Chinese name, symbol and flag
00:00 +4: kCurrencyMeta CNY entry matches the spec exactly
00:00 +5: currencyOf returns the meta entry for a known code
00:00 +6: currencyOf returns a code-only fallback for an unknown code
00:00 +7: constants ApiConst exposes base URL and timeout
00:00 +8: constants CacheKey exposes the storage keys
00:00 +9: constants default base and target are CNY and USD
00:00 +10: constants kDefaultCurrencies is the exact 10-code list from the brief
00:00 +11: All tests passed!
```
All 11 tests pass.

### Step 3 — `flutter analyze lib/models lib/core`
```
Analyzing 2 items...
No issues found! (ran in 0.9s)
```
Matches brief expectation `No issues found!`.

### Step 4 — `flutter test` (full suite)
```
00:00 +0: loading /Users/jason/developer/flutter_worksapce/currency_exchange_rate/exchange_rate/test/widget_test.dart
00:00 +0: /Users/jason/developer/flutter_worksapce/currency_exchange_rate/exchange_rate/test/currency_meta_test.dart: Currency holds the four required fields
00:00 +1: /Users/jason/developer/flutter_worksapce/currency_exchange_rate/exchange_rate/test/widget_test.dart: PlaceholderApp renders title
00:00 +2..+11: (currency_meta + widget tests intermixed)
00:01 +12: All tests passed!
```
12 tests pass across the two test files.

### Step 5 — Stage only in-scope files, then commit
```
$ git add lib/models/currency.dart lib/core/currency_meta.dart lib/core/constants.dart test/currency_meta_test.dart
$ git status
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   lib/core/constants.dart
	new file:   lib/core/currency_meta.dart
	new file:   lib/models/currency.dart
	new file:   test/currency_meta_test.dart

Changes not staged for commit:
	modified:   ios/Flutter/Debug.xcconfig
	modified:   ios/Flutter/Release.xcconfig
Untracked files:
	ios/Podfile
```
Only the four Task-2 files are staged. iOS-side working-tree noise (Debug/Release.xcconfig, Podfile) was left untouched as instructed.

```
$ git commit -m "feat: add currency model and metadata"
[main b1d6719] feat: add currency model and metadata
 4 files changed, 163 insertions(+)
 create mode 100644 lib/core/constants.dart
 create mode 100644 lib/core/currency_meta.dart
 create mode 100644 lib/models/currency.dart
 create mode 100644 test/currency_meta_test.dart

$ git rev-parse HEAD
b1d671908b6af130b3513b31383d94e23d8a66ed
```

## Concerns
- Same pre-existing working-tree noise as Task 1 (`ios/Flutter/Debug.xcconfig`, `ios/Flutter/Release.xcconfig`, untracked `ios/Podfile`). Not touched, not staged, per scope.
- Brief lists three files in the commit example; I additionally committed `test/currency_meta_test.dart` because it is the failing-first-then-passing test that drives this Task per the TDD requirement in the brief. Excluding it would leave the repo without evidence of the acceptance tests. Deliberate, in-scope.
- The `symbol` field for USD/AUD/HKD/CAD/SGD is `$` and JPY is `¥` (matches CNY's symbol) — this is what the brief specifies. If later formatting logic needs to distinguish these currencies visually, it will have to rely on `code`/`cnName`/`flag`, not `symbol` alone.
