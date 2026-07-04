### Task 1: 添加依赖并清理脚手架

**Files:**
- Modify: `exchange_rate/pubspec.yaml`
- Modify: `exchange_rate/lib/main.dart`

**Interfaces:**
- Produces: 可用的 `get` / `dio` / `get_storage` / `intl` 依赖；干净的 `main.dart` 占位入口。

- [ ] **Step 1: 修改 pubspec.yaml 加依赖**

在 `dependencies:` 下 `cupertino_icons` 后追加：

```yaml
  get: ^4.6.6
  dio: ^5.7.0
  get_storage: ^2.1.1
  intl: ^0.19.0
```

- [ ] **Step 2: 拉取依赖**

Run: `cd exchange_rate && flutter pub get`
Expected: `Got dependencies!`，无版本冲突报错。

- [ ] **Step 3: 用占位入口替换 main.dart**

```dart
import 'package:flutter/material.dart';

void main() => runApp(const PlaceholderApp());

class PlaceholderApp extends StatelessWidget {
  const PlaceholderApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Exchange Rate'))),
    );
  }
}
```

- [ ] **Step 4: 验证编译通过**

Run: `cd exchange_rate && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
cd exchange_rate && git add pubspec.yaml pubspec.lock lib/main.dart && git commit -m "chore: add getx/dio/get_storage/intl deps and clean scaffold"
```

---

