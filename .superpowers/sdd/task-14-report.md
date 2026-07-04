# Task 14 Report — RatesPage 行情列表页

## 状态
DONE

## Commit
- Hash: `bbad13b`
- Message: `feat: add rates list page with search and pull-to-refresh`
- Verified via `git log -1 --oneline` after commit.

## Files changed
- `lib/views/rates/rates_page.dart` (new)
- `lib/views/home/home_page.dart` (modified: import + 第二个占位替换为 `RatesPage()`)
- `test/views/rates/rates_page_test.dart` (new — 5 widget tests)
- `test/views/home/home_page_test.dart` (modified: 增加 `RatesController` 的 in-memory 注入)

## TDD 执行过程
1. 先写失败的 widget 测试 `test/views/rates/rates_page_test.dart`，运行 `fvm flutter test test/views/rates/rates_page_test.dart` 确认失败：
   ```
   test/views/rates/rates_page_test.dart:8:8: Error: Error when reading 'lib/views/rates/rates_page.dart': No such file or directory
   test/views/rates/rates_page_test.dart:49:42: Error: Couldn't find constructor 'RatesPage'.
   ...
   00:00 +0 -1: Some tests failed.
   ```
2. 实现 `lib/views/rates/rates_page.dart`（按 brief 的模板；修复了 `(_, __)` 的 lint hint，改为 `(_, _)`）。
3. 重新运行仅 rates 页面 widget 测试：
   ```
   00:00 +5: All tests passed!
   ```
4. 修改 `home_page.dart`：`import '../rates/rates_page.dart';` + `_pages` 第二项改为 `RatesPage()`。
5. 修改 `home_page_test.dart`：`setUp` 中 `Get.put(RatesController(repo: repo))`（共用同一个 in-memory `RateRepository` stub），使 HomePage 切到 index=1 也能构建 RatesPage。

## Verification 输出

### `fvm flutter analyze lib/views/rates lib/views/home`
```
Analyzing 2 items...
No issues found! (ran in 2.4s)
```

### `fvm flutter test test/views/rates/rates_page_test.dart test/views/home/home_page_test.dart`
```
00:00 +9: All tests passed!
```
（RatesPage 5 个 widget 测试 + HomePage 4 个 widget 测试全部通过。）

### 全量 `fvm flutter test`
```
00:00 +46: All tests passed!
```
（46 个测试全部通过，未破坏既有测试。）

## RatesPage 关键交互覆盖（测试项）
- AppBar 标题 `行情` + 搜索 TextField + `Icons.search` 图标
- `load()` 后渲染非报价币种行，且展示 `1 USD ≈ 7.2600 CNY` 格式；`CNY`（报价币）被过滤掉
- 搜索框输入 `USD` 时列表只剩 `USD` 行，`EUR`/`JPY` 消失
- 搜索无匹配时显示 `没有匹配的币种`
- `RefreshIndicator` 作为下拉刷新容器包裹列表

## HomePage 集成
- 替换第二个占位后，`home_page_test.dart` 原有 4 个测试（labels/index 0/tap 行情→index 1/tap 设置→index 2）依然全部通过；`IndexedStack.children` 常量化保持不变。
- Widget test 仍使用 `Get.testMode = true` + in-memory `RateStorage`/`SettingsStorage` stub，避免 GetStorage 定时器泄漏。

## 变更范围守则
- 未触碰 `ios/` 下已有本地改动（Debug.xcconfig / Release.xcconfig / Podfile 仍处于 working tree unstaged 状态，未纳入本次 commit）。
- 仅 stage 了 `lib/views/rates`、`lib/views/home/home_page.dart` 以及对应两个测试文件。

## Concerns
无。所有 brief 步骤达成，全量测试和 analyze 通过。
