### Task 12: 路由、Binding、应用入口

**Files:**
- Create: `exchange_rate/lib/core/app_routes.dart`
- Create: `exchange_rate/lib/bindings/app_binding.dart`
- Modify: `exchange_rate/lib/main.dart`

**Interfaces:**
- Consumes: `HomePage`, `AppTheme`, `ApiClient`, `RateRepository`, 三个 Controller, `GetStorage`
- Produces:
  - `class Routes { static const home = '/home'; }`
  - `class AppPages { static final pages = [ GetPage(name: Routes.home, page: () => const HomePage(), binding: AppBinding()) ]; }`
  - `class AppBinding extends Bindings`：注入 `GetStorageAdapter`(实现 `RateStorage`)、`ApiClient`、`RateRepository`、三个 Controller（`Get.lazyPut`/`Get.put`）。
  - `class GetStorageAdapter implements RateStorage`（用 `GetStorage` 实现 read/write）。

- [ ] **Step 1: 创建 GetStorageAdapter + AppBinding**

`lib/bindings/app_binding.dart`：

```dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/api_client.dart';
import '../controllers/converter_controller.dart';
import '../controllers/rates_controller.dart';
import '../controllers/settings_controller.dart';
import '../repositories/rate_repository.dart';

class GetStorageAdapter implements RateStorage {
  final _box = GetStorage();
  @override
  Map<String, dynamic>? read(String key) {
    final v = _box.read(key);
    return v == null ? null : Map<String, dynamic>.from(v);
  }

  @override
  Future<void> write(String key, Map<String, dynamic> value) =>
      _box.write(key, value);
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    final repo = RateRepository(
      api: ApiClient(),
      storage: GetStorageAdapter(),
    );
    Get.put<RateRepository>(repo, permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(ConverterController(repo: repo));
    Get.put(RatesController(repo: repo));
  }
}
```

- [ ] **Step 2: 创建 app_routes.dart**

```dart
import 'package:get/get.dart';
import '../bindings/app_binding.dart';
import '../views/home/home_page.dart';

class Routes {
  static const String home = '/home';
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: AppBinding(),
    ),
  ];
}
```

- [ ] **Step 3: 重写 main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'core/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final dark = GetStorage().read(CacheKey.themeMode) ?? false;
  runApp(ExchangeRateApp(startDark: dark));
}

class ExchangeRateApp extends StatelessWidget {
  final bool startDark;
  const ExchangeRateApp({super.key, required this.startDark});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '汇率换算',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: startDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: Routes.home,
      getPages: AppPages.pages,
    );
  }
}
```

- [ ] **Step 4: 验证编译并运行 analyze**

Run: `cd exchange_rate && flutter analyze`
Expected: `No issues found!`（HomePage 仍是占位页，可正常启动）

- [ ] **Step 5: Commit**

```bash
cd exchange_rate && git add lib/core/app_routes.dart lib/bindings/app_binding.dart lib/main.dart && git commit -m "feat: wire up routes, binding and app entry"
```

---



---
**环境提示（重要）**：本机用 fvm 管理 Flutter，所有命令必须加 `fvm` 前缀：`fvm flutter analyze`、`fvm flutter test`、`fvm dart ...`。裸 flutter 可能指向错误版本。

**报告落地要求（重要）**：完成后必须真实执行 `git commit` 并用 `git log -1 --format= 验证 commit 已落地，回报真实 commit hash（前一个 Task 曾谎报提交但未落地，务必先 git log 确认）。

**跨任务上下文**：
- `SettingsController` 的构造签名是 `SettingsController({SettingsStorage? storage})`（Task 9 引入注入式存储）。生产路径直接 `Get.put(SettingsController())` 即可，默认走 GetStorage。
- `RateStorage` 抽象签名（Task 5/6）：`Map<String,dynamic>? read(String key)` 和 `Future<void> write(String key, Map<String,dynamic> value)`，brief 里的 `GetStorageAdapter` 已正确匹配。
- `ConverterController` / `RatesController` 构造签名均为 `({required RateRepository repo})`。
