# Task 8 Report: RatesController

## 状态
DONE

## Commit
`cf8dbc8` — feat: add rates controller with search filter

## 变更文件
- `lib/controllers/rates_controller.dart` (新增)
- `test/controllers/rates_controller_test.dart` (新增)

## TDD 流程与命令输出

### Step 1: 写失败测试
新建 `test/controllers/rates_controller_test.dart`，逐字采用 brief 中的测试片段（含 `_StubApi`、`_MemStorage`、两个测试用例）。

### Step 2: 运行确认失败
命令：`fvm flutter test test/controllers/rates_controller_test.dart`

输出（关键段）：
```
test/controllers/rates_controller_test.dart:2:8: Error: Error when reading 'lib/controllers/rates_controller.dart': No such file or directory
test/controllers/rates_controller_test.dart:27:8: Error: 'RatesController' isn't a type.
test/controllers/rates_controller_test.dart:29:9: Error: Method not found: 'RatesController'.
Failed to load ... Compilation failed
Some tests failed.
```
确认按预期失败（`RatesController` 未定义）。

### Step 3: 最小实现
新建 `lib/controllers/rates_controller.dart`，按 brief 逐字实现：
- `RateRow(currency, rate)` 数据类
- `RatesController extends GetxController`，字段 `quote`(默认 CNY)、`search`、`table`(Rxn)、`isLoading`
- `rows` getter：跳过 quote 币种，按 `search` 大小写不敏感过滤 code / cnName
- `onInit()` 自动 `load()`
- `load({forceRefresh})`：走 `repo.getRates`，`ApiException` 静默保留上次数据

### Step 4: 单测通过
命令：`fvm flutter test test/controllers/rates_controller_test.dart`

输出：
```
00:00 +0: loading .../rates_controller_test.dart
00:00 +0: rows 生成非基准币种行且换算为 CNY
00:00 +1: search 过滤
00:00 +2: All tests passed!
```

### Step 4b: 全套测试通过（未打破前序）
命令：`fvm flutter test`

输出（结尾）：
```
00:00 +27: All tests passed!
```
27 个测试全部通过（含 currency_meta、exchange_rate_table、rate_repository、converter_controller、rates_controller、widget_test）。

### Step 5: analyze 无告警
命令：`fvm flutter analyze lib/controllers test/controllers`

输出：
```
Analyzing 2 items...
No issues found! (ran in 1.6s)
```

### Step 6: Commit
命令：`git add lib/controllers/rates_controller.dart test/controllers/rates_controller_test.dart && git commit -m "feat: add rates controller with search filter"`

输出：
```
[main cf8dbc8] feat: add rates controller with search filter
 2 files changed, 107 insertions(+)
 create mode 100644 lib/controllers/rates_controller.dart
 create mode 100644 test/controllers/rates_controller_test.dart
```

只 stage 了本任务的两个文件；`ios/Flutter/*.xcconfig` 与 `ios/Podfile` 的无关改动保持未 stage（按约束不触碰）。

## Concerns
无。所有测试通过，analyze 无告警，接口与 brief 完全一致。
