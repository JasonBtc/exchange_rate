# Task 13 Report: ConverterPage + Currency Picker

## Status
DONE

## Commit
`b793334 feat: add converter page with currency picker`

Verified via `git log -1 --oneline`:
```
b793334 feat: add converter page with currency picker
```

## Files Changed
- `lib/views/converter/converter_page.dart` (new)
- `lib/views/converter/widgets/currency_picker.dart` (new)
- `lib/views/home/home_page.dart` (modified: import + `_pages` first entry replaced with `ConverterPage()`)
- `test/views/converter_page_test.dart` (new)
- `test/views/home/home_page_test.dart` (modified: added Get.testMode + setUp/tearDown to register ConverterController & SettingsController so the widget tree can build ConverterPage inside HomePage)

Only these files were staged. `ios/Flutter/Debug.xcconfig`, `ios/Flutter/Release.xcconfig`, and untracked `ios/Podfile` were intentionally left out of the commit.

## TDD Steps

### Step 1: Failing widget test written
`test/views/converter_page_test.dart` — imports `ConverterPage`, seeds Get with `SettingsController` (in-memory `SettingsStorage`) and `ConverterController` (in-memory `RateStorage` + stub `ApiClient`), sets amount 726 CNY, asserts `find.textContaining('100')` (because 726 CNY ≈ 100 USD from the stub rate 7.26).

### Step 2: Ran to confirm failure
```
fvm flutter test test/views/converter_page_test.dart
```
Output:
```
test/views/converter_page_test.dart:8:8: Error: Error when reading 'lib/views/converter/converter_page.dart': No such file or directory
test/views/converter_page_test.dart:37:56: Error: Method not found: 'ConverterPage'.
Compilation failed for testPath=...
Some tests failed.
```

### Step 3: Implemented `currency_picker.dart`
Verbatim per brief — `showCurrencyPicker` opens a `showModalBottomSheet` listing `kDefaultCurrencies` with flag / cn name / code and a check mark for the current selection; returns the tapped code via `Navigator.pop`.

### Step 4: Implemented `converter_page.dart`
Verbatim per brief — `Scaffold` + `AppBar('实时换算')` + `RefreshIndicator` wrapping a `ListView`:
- Dark converter card (`Color(0xFF1B1E27)`) with amount `TextField` → base chip, divider, result `Text(c.result.toStringAsFixed(settings.decimals.value))` → target chip; chips tap → `showCurrencyPicker`.
- `FilledButton.tonalIcon` swap button.
- Error card (only when `c.error.value != null`).
- Unit-rate summary card with `updatedAt`.

Everything reactive via `Obx`; `settings.decimals.value` drives the result precision.

### Step 5: Wired into `home_page.dart`
Added `import '../converter/converter_page.dart';` and replaced first entry of `_pages` with `ConverterPage()`. Kept the list `final` (dropped `const` because `ConverterPage()` construction happens per navigation destination, and the list still contains const-instantiable elements — analyzer clean).

### Step 6: Ran to confirm pass
```
fvm flutter test test/views/converter_page_test.dart
```
Output:
```
00:00 +0: loading .../converter_page_test.dart
00:00 +0: (setUpAll)
00:00 +0: 显示结果数值
00:00 +1: (tearDownAll)
00:00 +1: All tests passed!
```

Note: initial run of the widget test tripped over `GetStorage._internal` scheduling a `Timer.run` during `SettingsController` construction (because the widget test binding is a `FakeAsync`, the pending timer left the tree). Fixed by injecting the in-memory `SettingsStorage` (matches the shape used by `settings_controller_test.dart`) and enabling `Get.testMode = true` in `setUpAll`. No production code change needed.

## Fixing Home Page Tests
Modifying `home_page.dart` to build `ConverterPage()` broke `test/views/home/home_page_test.dart` because those tests hadn't seeded Get with `ConverterController` / `SettingsController`. Added `Get.testMode = true` in `setUpAll` plus `setUp` that registers both controllers with in-memory stubs, and `tearDown` calling `Get.reset()`. All four HomePage widget tests pass.

## Verification

### `fvm flutter analyze`
```
Analyzing exchange_rate...
No issues found! (ran in 1.4s)
```

### `fvm flutter test` (full suite)
```
00:02 +41: All tests passed!
```
41 tests, 0 failures across `app_theme_test`, `rate_repository_test`, `exchange_rate_table_test`, `converter_controller_test`, `rates_controller_test`, `settings_controller_test`, `home_page_test`, `converter_page_test`, `currency_meta_test`, `widget_test`.

### `git log -1 --oneline`
```
b793334 feat: add converter page with currency picker
```

## Concerns
None. Everything runs green, no analyzer warnings, iOS-local changes untouched.
