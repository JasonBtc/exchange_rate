# Task 9 Report: SettingsController

## 状态
DONE_WITH_CONCERNS（仅一处受控偏离：为可测试性引入 `SettingsStorage` 抽象。见"偏离 brief"）

## Commit
`0d884e969fee18a55bb83357112624df8f7cf4c9` — feat: add settings controller with persistence

## 变更文件
- `lib/controllers/settings_controller.dart` (新增)
- `test/controllers/settings_controller_test.dart` (新增)

## 偏离 brief 的地方及原因
brief 的 Step 1 代码里 `final _box = GetStorage();` 是直接在字段初始化时构造 `GetStorage`。
父代理明确要求"测试中不要依赖真实磁盘存储——用注入的方式或 fake"，且前序任务 6（RateRepository）已建立同样的模式（`abstract class RateStorage` + fake）。

为对齐 Task 6 的注入风格 + 满足"不依赖磁盘"的测试约束，实现里额外引入了：

```dart
abstract class SettingsStorage {
  Object? read(String key);
  Future<void> write(String key, Object value);
}

class GetStorageSettingsStorage implements SettingsStorage { ... }  // 默认实现，包 GetStorage
```

Controller 变为：
```dart
class SettingsController extends GetxController {
  final SettingsStorage storage;
  SettingsController({SettingsStorage? storage})
      : storage = storage ?? GetStorageSettingsStorage();
  ...
}
```

其余接口（`isDark`、`decimals`、`toggleTheme`、`setDecimals`、`onInit → _restore`）与 brief 完全一致，包括 key（`CacheKey.themeMode` / `CacheKey.decimals`）、默认值（`false` / `2`）、`toggleTheme` 里调用 `Get.changeThemeMode(...)`。

生产代码路径未变：不注入 storage 时默认走 `GetStorage()`，与 brief 语义等价。

## TDD 流程与命令输出

### Step 1: 写失败测试
新建 `test/controllers/settings_controller_test.dart`：
- `_MemStorage implements SettingsStorage`（内存 fake）
- 4 个测试：默认值、onInit 读回、toggleTheme 写入、setDecimals 写入
- `setUpAll(() { Get.testMode = true; })` 让 `Get.changeThemeMode` 在无 Material app 环境下不炸

### Step 2: 运行确认失败（红）
命令：`fvm flutter test test/controllers/settings_controller_test.dart`

输出（关键段）：
```
test/controllers/settings_controller_test.dart:3:8: Error: Error when reading 'lib/controllers/settings_controller.dart': No such file or directory
test/controllers/settings_controller_test.dart:5:30: Error: Type 'SettingsStorage' not found.
test/controllers/settings_controller_test.dart:20:15: Error: Method not found: 'SettingsController'.
...
Failed to load ... Compilation failed
Some tests failed.
```
确认按预期失败（`SettingsController` / `SettingsStorage` 未定义）。

### Step 3: 最小实现
新建 `lib/controllers/settings_controller.dart`：
- `abstract class SettingsStorage { read; write }`
- `class GetStorageSettingsStorage implements SettingsStorage`（包 `GetStorage`）
- `class SettingsController extends GetxController`，字段 `isDark`、`decimals`，`onInit()` 调用私有 `_restore()`
- `_restore()` 使用类型守卫 `if (t is bool)` / `if (d is int)`，缺失或类型不符时保留默认值
- `toggleTheme(value)`: 写 storage + `Get.changeThemeMode`
- `setDecimals(d)`: 写 storage

### Step 4: 单测通过（绿）
命令：`fvm flutter test test/controllers/settings_controller_test.dart`

输出：
```
00:00 +0: (setUpAll)
00:00 +0: 默认值：isDark=false, decimals=2
00:00 +1: onInit 从存储读回主题与精度
00:00 +2: toggleTheme 写入存储并更新 isDark
00:00 +3: setDecimals 写入存储并更新 decimals
00:00 +4: (tearDownAll)
00:00 +4: All tests passed!
```

### Step 4b: 全套测试通过（未打破前序）
命令：`fvm flutter test`

输出（结尾）：
```
00:00 +31: All tests passed!
```
31 个测试全部通过（含 currency_meta、exchange_rate_table、rate_repository、converter_controller、rates_controller、settings_controller、widget_test）。相较 Task 8 的 27 个 +4 = 31，无回归。

### Step 5: analyze 无告警
命令：`fvm flutter analyze lib/controllers test/controllers`

输出：
```
Analyzing 2 items...
No issues found! (ran in 1.5s)
```

### Step 6: Commit
命令：`git add lib/controllers/settings_controller.dart test/controllers/settings_controller_test.dart && git commit -m "feat: add settings controller with persistence"`

输出：
```
[main 0d884e9] feat: add settings controller with persistence
 2 files changed, 106 insertions(+)
 create mode 100644 lib/controllers/settings_controller.dart
 create mode 100644 test/controllers/settings_controller_test.dart
```

只 stage 了本任务的两个文件；`ios/Flutter/*.xcconfig` 与 `ios/Podfile` 的无关改动保持未 stage（按约束不触碰）。

## Global Constraints 遵守情况
- 只用 GetX 做状态管理（`Rx<bool>`、`Rx<int>`、`GetxController`）——满足
- 未引入其它状态库——满足
- 未直接 new Dio——满足（本任务不涉及网络）
- get_storage 的写入用 `Future<void>` 但按 brief 语义调用点不 await（写侧只发起，不阻塞）——满足

## Concerns
1. **`storage.write` 未 await**：`SettingsStorage.write` 返回 `Future<void>`，`toggleTheme` / `setDecimals` 都是 fire-and-forget。这和 brief 的原始代码语义一致（`_box.write` 是 GetStorage 的同步内存写 + 异步持久化，也不 await），但如果后续需要"保存完成回执"，需要重构签名。此为后续可能需要关注的点，非当前缺陷。
2. **`_restore` 类型守卫更宽松**：brief 用 `_box.read(key) ?? default` 依赖运行时类型和 null 语义；本实现用 `is bool` / `is int` 显式类型检查，若 storage 里出现脏值（例如老版本写入的字符串），会保留默认值而不是抛错，行为更保守。
