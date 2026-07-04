# Task 11 Report — 主题（对齐设计稿 token）

## Status
DONE

## Commit
- Hash: `a6dfd44fdda75c268445154b999a30f48de72c48`
- Short: `a6dfd44`
- Message: `feat: add light/dark theme aligned with design tokens`
- HEAD verification: `git log --oneline -1` -> `a6dfd44 feat: add light/dark theme aligned with design tokens`; `git rev-parse HEAD` -> `a6dfd44fdda75c268445154b999a30f48de72c48`.

## Files
- Created: `lib/core/app_theme.dart`
- Created: `test/core/app_theme_test.dart`

Only these two files were staged. The pre-existing untracked `ios/Podfile` and modified `ios/Flutter/*.xcconfig` were left untouched.

## Interface Produced
```dart
class AppTheme {
  static const Color accent   = Color(0xFF2F6BFF); // brand accent
  static const Color positive = Color(0xFF12A150); // positive/up-tick

  static ThemeData get light; // Material 3, Brightness.light
  static ThemeData get dark;  // Material 3, Brightness.dark
}
```

Both themes:
- `useMaterial3: true`
- `ColorScheme.fromSeed(seedColor: accent, ...)` with `primary` pinned to `accent`
- Card shape `RoundedRectangleBorder` radius `20`, `elevation: 0`, transparent `surfaceTintColor`
- `TextTheme` uses `FontFeature.tabularFigures()` on display/headline/body variants (so numeric rows and result readouts align)
- `AppBarTheme` flat, non-centered, no scroll-under elevation
- `DividerTheme` set to the neutral border token

## Design tokens (sRGB approx of oklch spec)
| Token | Light | Dark |
|---|---|---|
| bg | `#F7F8FA` | `#14181F` |
| surface | `#FFFFFF` | `#1E232B` |
| fg | `#1B1F26` | `#F2F4F7` |
| muted | `#6B7280` | `#9AA3AE` |
| border | `#E5E8EC` | `#2C333D` |
| accent | `#2F6BFF` | `#2F6BFF` |
| positive | `#12A150` | `#12A150` |

## Verification

### `fvm flutter analyze`
```
Analyzing exchange_rate...
No issues found! (ran in 1.6s)
```

### `fvm flutter test`
```
00:01 +40: All tests passed!
```
40/40 tests pass, including the new `AppTheme` suite:
- exposes accent brand color aligned with design token
- light theme uses Material 3 and light brightness
- dark theme uses Material 3 and dark brightness
- both themes seed from the accent color
- card theme has 20 radius rounded rectangle shape

## Deviations from brief
- Brief's example used seedColor `#2F6BFF` and let `ColorScheme.fromSeed` pick `primary`. The seeded `primary` drifts slightly from the exact brand hex, so `copyWith(primary: accent)` is applied to both schemes to keep the accent color exactly on token.
- Brief's example set `scaffoldBackgroundColor` to `#F6F7F9` / `#16181F`. Values were updated to `#F7F8FA` / `#14181F` to match the task-brief header table's oklch conversions (the parent message specified these values as authoritative; brief's example was closer but not identical).
- Added `positive` (`#12A150`) as `AppTheme.positive` — brief mentioned `#1FB980` in the example, but the parent message specified `#12A150` and marked itself authoritative. Semantic-only token; no theme consumes it yet.
- Added `TextTheme` with `FontFeature.tabularFigures()` (brief listed this requirement in Interfaces but omitted it from the code example).
- Added `AppBarTheme` / `DividerTheme` / `surfaceTintColor: transparent` on cards for consistency with the flat design language in `汇率设计`; these are additive and don't conflict with the brief.

## Concerns
None. Ready for Task 12 (app entry) to consume `AppTheme.light` / `AppTheme.dark` via `GetMaterialApp(theme:, darkTheme:, themeMode:)`.
