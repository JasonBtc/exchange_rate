# Task 3 Report: Dio 网络客户端封装

## Status
DONE

## Commit
- SHA: `e32ad6c`
- Message: `feat: add dio api client with error handling`

## Files Changed
- Created: `lib/core/api_client.dart` (33 lines, added in this commit)

## Commands Run & Real Output

### 1. Pre-check: confirm constants.dart exports & dio dep
```
$ ls -la lib/core/
total 16
drwxr-xr-x  4 jason  staff   128 Jul  3 20:42 .
drwxr-xr-x@ 5 jason  staff   160 Jul  3 20:42 ..
-rw-r--r--  1 jason  staff   493 Jul  3 20:41 constants.dart
-rw-r--r--  1 jason  staff  1050 Jul  3 20:42 currency_meta.dart
```
Confirmed `ApiConst.base = 'https://open.er-api.com/v6/latest'` and `ApiConst.timeout = Duration(seconds: 15)` already present. `dio: ^5.7.0` is declared in `pubspec.yaml`.

### 2. Static analysis (brief Step 2)
```
$ flutter analyze lib/core/api_client.dart
Analyzing api_client.dart...
No issues found! (ran in 0.8s)
```
Matches expected `No issues found!`.

### 3. Commit (brief Step 3)
```
$ git add lib/core/api_client.dart && git commit -m "feat: add dio api client with error handling"
[main e32ad6c] feat: add dio api client with error handling
 1 file changed, 33 insertions(+)
 create mode 100644 lib/core/api_client.dart
```

### 4. Post-commit status
```
$ git status --short
 M ios/Flutter/Debug.xcconfig
 M ios/Flutter/Release.xcconfig
?? ios/Podfile
```
Unrelated iOS files left untouched and unstaged, as instructed.

## TDD Note
No unit test written for `ApiClient`. Rationale: the brief prescribes a thin `Dio` wrapper and does not specify tests; behavior is a straight passthrough (HTTP GET + result-field check + `DioException` -> `ApiException` remap). Real coverage will come via the Repository layer (Task 5), which can inject a `MockAdapter` on the `Dio` instance if needed. Flagging as an information item, not a concern.

## Contract Delivered
- `class ApiException implements Exception { final String message; ... }`
- `class ApiClient { ApiClient({Dio? dio}); Future<Map<String, dynamic>> getLatest(String base); }`
  - GETs `${ApiConst.base}/$base`
  - Returns raw map when `data['result'] == 'success'`
  - Throws `ApiException` on non-success payload or `DioException`
  - Timeouts sourced from `ApiConst.timeout`

## Concerns
None.
