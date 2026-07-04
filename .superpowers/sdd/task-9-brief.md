### Task 9: SettingsController（主题/精度）

**Files:**
- Create: `exchange_rate/lib/controllers/settings_controller.dart`

**Interfaces:**
- Consumes: `CacheKey.themeMode`, `CacheKey.decimals`, get_storage 的 `GetStorage`
- Produces（GetxController）:
  - `final isDark = false.obs;`
  - `final decimals = 2.obs;`（付款精度：2/4/6）
  - `void toggleTheme(bool value)`（写缓存 + `Get.changeThemeMode`）
  - `void setDecimals(int d)`（写缓存）
  - `void _restore()`（onInit 时从 get_storage 读回）

- [ ] **Step 1: 实现 settings_controller.dart**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/constants.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();
  final isDark = false.obs;
  final decimals = 2.obs;

  @override
  void onInit() {
    super.onInit();
    isDark.value = _box.read(CacheKey.themeMode) ?? false;
    decimals.value = _box.read(CacheKey.decimals) ?? 2;
  }

  void toggleTheme(bool value) {
    isDark.value = value;
    _box.write(CacheKey.themeMode, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void setDecimals(int d) {
    decimals.value = d;
    _box.write(CacheKey.decimals, d);
  }
}
```

- [ ] **Step 2: 验证编译**

Run: `cd exchange_rate && flutter analyze lib/controllers/settings_controller.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd exchange_rate && git add lib/controllers/settings_controller.dart && git commit -m "feat: add settings controller with persistence"
```

---



## 环境说明
本地用 fvm 管理 Flutter，所有命令加 fvm 前缀：`fvm flutter test`、`fvm flutter analyze`、`fvm flutter pub get`。
