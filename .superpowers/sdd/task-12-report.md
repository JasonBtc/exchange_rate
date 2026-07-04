# Task 12 Report — 路由 + Binding + 应用入口接线

## Status
DONE_WITH_CONCERNS

## Commit
- Hash: `2d795a81dce76b22070cf49bdbfa94339796b777`
- Subject: `feat: wire up routes, binding and app entry`
- Branch: `main`
- Parent: `a6dfd44` (Task 11)

## Files Touched (staged in this commit)
- `lib/bindings/app_binding.dart` (new, 34 lines)
- `lib/core/app_routes.dart` (new, 17 lines)
- `lib/main.dart` (rewritten, +28/-9)
- `test/widget_test.dart` (updated, +5/-4) — see Concerns

Total: 4 files changed, 79 insertions(+), 9 deletions(-)

Intentionally NOT staged (pre-existing local edits unrelated to this task):
- `ios/Flutter/Debug.xcconfig` (modified)
- `ios/Flutter/Release.xcconfig` (modified)
- `ios/Podfile` (untracked)

## Deviation from brief
The brief only listed three files. However the default Flutter scaffold's
`test/widget_test.dart` still imported `PlaceholderApp` from the old
`main.dart`. The brief-mandated rewrite of `main.dart` removes
`PlaceholderApp`, which turned `flutter analyze` red:

```
error • The name 'PlaceholderApp' isn't a class • test/widget_test.dart:7:35 • creation_with_non_type
1 issue found.
```

Because Step 4 of the brief requires analyze to be `No issues found!`, I
updated `test/widget_test.dart` to pump `ExchangeRateApp(startDark: false)`
and assert the NavigationBar's `换算` destination renders (the initial
route lands on HomePage). This is the minimal surgical fix — no other
tests were touched.

## Commands & Real Outputs

### 1. `fvm flutter analyze` (final)
```
Analyzing exchange_rate...
No issues found! (ran in 2.0s)
```

### 2. `fvm flutter test` (final)
```
00:01 +40: All tests passed!
```
40 tests across 9 files, all green. Full test file list:

- `test/core/app_theme_test.dart`
- `test/currency_meta_test.dart`
- `test/models/exchange_rate_table_test.dart`
- `test/repositories/rate_repository_test.dart`
- `test/controllers/converter_controller_test.dart`
- `test/controllers/rates_controller_test.dart`
- `test/controllers/settings_controller_test.dart`
- `test/views/home/home_page_test.dart`
- `test/widget_test.dart`

### 3. Commit + verification
```
$ git add lib/bindings/app_binding.dart lib/core/app_routes.dart lib/main.dart test/widget_test.dart
$ git commit -m "feat: wire up routes, binding and app entry"
[main 2d795a8] feat: wire up routes, binding and app entry
 4 files changed, 79 insertions(+), 9 deletions(-)
 create mode 100644 lib/bindings/app_binding.dart
 create mode 100644 lib/core/app_routes.dart

$ git log -1 --format='%H %s'
2d795a81dce76b22070cf49bdbfa94339796b777 feat: wire up routes, binding and app entry

$ git log --oneline -3
2d795a8 feat: wire up routes, binding and app entry
a6dfd44 feat: add light/dark theme aligned with design tokens
6206176 feat: add home shell with bottom navigation
```

Verified: commit is real, on top of `a6dfd44`, and shown by `git log`.

## Concerns / Minor Findings
1. **widget_test.dart edit** — extended the brief's stated file list.
   Motivation and scope documented above; alternatives (deleting the test
   entirely, or moving the fix into Task 16) would leave analyze red now
   and break the "Step 4 expects No issues found!" gate.
2. **AppBinding uses `Get.put` for all four dependencies** — matches the
   brief verbatim. Repo + SettingsController are marked `permanent: true`;
   the two page-scoped controllers are non-permanent, so GetX will drop
   them on route disposal. This is fine while `/home` is the only route,
   but revisit if future work adds routes that should share those
   controllers.
3. **`main.dart` reads `themeMode` synchronously** to pick a startup
   `ThemeMode`. `SettingsController.onInit` re-reads it and drives runtime
   toggles via `Get.changeThemeMode`, so there's no drift — both read the
   same `CacheKey.themeMode` key.
