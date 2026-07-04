### Task 3: Dio 网络客户端封装

**Files:**
- Create: `exchange_rate/lib/core/api_client.dart`

**Interfaces:**
- Consumes: `ApiConst.base`, `ApiConst.timeout`
- Produces:
  - `class ApiClient { ApiClient({Dio? dio}); Future<Map<String, dynamic>> getLatest(String base); }`
  - `getLatest` 请求 `${ApiConst.base}/$base`，返回解析后的 JSON map；网络失败抛 `ApiException`。
  - `class ApiException implements Exception { final String message; }`

- [ ] **Step 1: 创建 api_client.dart**

```dart
import 'package:dio/dio.dart';
import 'constants.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: ApiConst.timeout,
              receiveTimeout: ApiConst.timeout,
            ));

  Future<Map<String, dynamic>> getLatest(String base) async {
    try {
      final resp = await _dio.get('${ApiConst.base}/$base');
      final data = resp.data;
      if (data is Map<String, dynamic> && data['result'] == 'success') {
        return data;
      }
      throw ApiException('接口返回异常: ${data is Map ? data['result'] : data}');
    } on DioException catch (e) {
      throw ApiException('网络请求失败: ${e.message}');
    }
  }
}
```

- [ ] **Step 2: 验证编译**

Run: `cd exchange_rate && flutter analyze lib/core/api_client.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd exchange_rate && git add lib/core/api_client.dart && git commit -m "feat: add dio api client with error handling"
```

---

