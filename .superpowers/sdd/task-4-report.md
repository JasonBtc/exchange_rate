# Task 4 Report: 汇率表模型与交叉汇率计算

## Status
DONE

## Commit
`9577c0d08c3a4c58bd78e8889a3ea8932b5d3049`

Commit message: `feat: add exchange rate table with cross-rate calculation`

Files committed:
- `lib/models/exchange_rate_table.dart` (created)
- `test/models/exchange_rate_table_test.dart` (created)

`ios/Flutter/Debug.xcconfig`, `ios/Flutter/Release.xcconfig`, `ios/Podfile` were left untouched/unstaged as instructed.

## TDD Flow

### Step 1+2: Write failing test, confirm failure

Wrote `test/models/exchange_rate_table_test.dart` verbatim from the brief.

Command: `fvm flutter test test/models/exchange_rate_table_test.dart`

Output (excerpt):
```
test/models/exchange_rate_table_test.dart:2:8: Error: Error when reading 'lib/models/exchange_rate_table.dart': No such file or directory
import 'package:exchange_rate/models/exchange_rate_table.dart';
       ^
test/models/exchange_rate_table_test.dart:5:17: Error: Method not found: 'ExchangeRateTable'.
...
00:00 +0 -1: Some tests failed.
```

Failure confirmed as expected (compile error, `ExchangeRateTable` undefined).

### Step 3+4: Implement, confirm pass

Wrote `lib/models/exchange_rate_table.dart` verbatim from the brief.

Command: `fvm flutter test test/models/exchange_rate_table_test.dart`

Output:
```
00:00 +0: loading /Users/jason/developer/flutter_worksapce/currency_exchange_rate/exchange_rate/test/models/exchange_rate_table_test.dart
00:00 +0: rate 计算交叉汇率 CNY->USD
00:00 +1: rate USD->CNY 等于牌价
00:00 +2: convert 金额换算
00:00 +3: 未知币种返回 null
00:00 +4: fromApi 解析 rates 与时间
00:00 +5: toJson/fromJson 往返一致
00:00 +6: isFromToday 同天判断
00:00 +7: All tests passed!
```

All 7 tests pass.

### Static analysis

Command: `fvm flutter analyze lib/models`

Output:
```
Analyzing models...
No issues found! (ran in 0.4s)
```

### Step 5: Commit

Command:
```
git add lib/models/exchange_rate_table.dart test/models/exchange_rate_table_test.dart
git commit -m "feat: add exchange rate table with cross-rate calculation"
```

Result:
```
[main 9577c0d] feat: add exchange rate table with cross-rate calculation
 2 files changed, 109 insertions(+)
 create mode 100644 lib/models/exchange_rate_table.dart
 create mode 100644 test/models/exchange_rate_table_test.dart
```

## Concerns
None.
