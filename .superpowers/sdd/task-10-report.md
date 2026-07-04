# Task 10 Report: HomePage 底部导航壳

## Status
**DONE**

## Commit
- Hash: `6206176`
- Message: `feat: add home shell with bottom navigation`
- Verified on HEAD via `git log --oneline -1` → `6206176 feat: add home shell with bottom navigation`
- Files changed (2 new, no modifications):
  - `lib/views/home/home_page.dart` (created)
  - `test/views/home/home_page_test.dart` (created)
- ios/ 下的无关改动（Debug.xcconfig / Release.xcconfig / Podfile）未 stage，保持工作区隔离

## TDD Cycle
1. **Red**: 先写 `test/views/home/home_page_test.dart`，`fvm flutter test` 报 `Compilation failed ... No such file or directory: 'package:exchange_rate/views/home/home_page.dart'` —— 符合预期的失败。
2. **Green**: 创建 `lib/views/home/home_page.dart`（`StatefulWidget` + `IndexedStack` + `NavigationBar` 三 tab，占位 `Center(Text)`）。
3. **Verify**: 单文件测试 4/4 通过；全量测试 35/35 通过；analyze 无 issue。

## Test Output (fvm flutter test — full suite)
```
00:00 +35: All tests passed!
```
新增的 4 个 HomePage 测试均通过：
- `renders three NavigationBar destinations with expected labels`
- `starts on the first tab (换算) via IndexedStack index 0`
- `tapping 行情 destination switches IndexedStack to index 1`
- `tapping 设置 destination switches IndexedStack to index 2`

其余 31 个前置任务的测试（models / repositories / controllers / currency_meta / widget_test）依旧全绿，未回归。

## Analyze Output (fvm flutter analyze)
```
Analyzing exchange_rate...
No issues found! (ran in 1.5s)
```

## 实现要点
- `HomePage` 为 `StatefulWidget`，内部 `_index` 管理当前 tab。
- `IndexedStack` 保持三页状态不丢失（后续 Task 13-15 只需替换 `_pages` 列表中的三个占位 `Center` 为真实页面，接口不变）。
- `NavigationBar`（Material 3）三个 destination：换算 / 行情 / 设置，图标分别 `swap_horiz` / `list_alt` / `settings`。
- 占位页留有明确注释：`// Task 13-15 完成后替换为 ConverterPage/RatesPage/SettingsPage`。

## Concerns
无。壳自洽、测试可跑通，等待 Task 13-15 完成后把 `_pages` 里的三个 `Center` 替换成真实页面即可，不涉及本文件其他结构改动。
