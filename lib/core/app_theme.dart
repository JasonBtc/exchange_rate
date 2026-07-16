import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme tokens aligned with the design spec in `汇率设计/css/app.css`.
///
/// Colors are converted from the design's `oklch` tokens to approximate
/// sRGB hex values. Card radius follows the spec (iOS 22 / Android 18,
/// unified to 20). Numeric text uses tabular figures so digits line up
/// in rate rows and result displays.
class AppTheme {
  const AppTheme._();

  // Brand accent — the single seed color for both schemes. Kept here (and
  // mirrored by AppColors.accent) as the brand entry point; other surface
  // colors live only in [AppColors] to avoid a second source of truth.
  static const Color accent = Color(0xFF2F6BFF);

  static const double _cardRadius = 20;

  static const List<FontFeature> _tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static ThemeData get light {
    const c = AppColors.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: accent,
      surface: c.surface,
      onSurface: c.fg,
      outline: c.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
    );

    return base.copyWith(
      textTheme: _applyTabularFigures(base.textTheme, c.fg, c.muted),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.fg,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      extensions: const [AppColors.light],
    );
  }

  static ThemeData get dark {
    const c = AppColors.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accent,
      surface: c.surface,
      onSurface: c.fg,
      outline: c.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
    );

    return base.copyWith(
      textTheme: _applyTabularFigures(base.textTheme, c.fg, c.muted),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1),
      extensions: const [AppColors.dark],
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.fg,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
    );
  }

  static TextTheme _applyTabularFigures(
    TextTheme base,
    Color fg,
    Color muted,
  ) {
    return base.apply(bodyColor: fg, displayColor: fg).copyWith(
          displayLarge: base.displayLarge?.copyWith(
            color: fg,
            fontFeatures: _tabularFigures,
          ),
          displayMedium: base.displayMedium?.copyWith(
            color: fg,
            fontFeatures: _tabularFigures,
          ),
          displaySmall: base.displaySmall?.copyWith(
            color: fg,
            fontFeatures: _tabularFigures,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            color: fg,
            fontFeatures: _tabularFigures,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            color: fg,
            fontFeatures: _tabularFigures,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            color: fg,
            fontFeatures: _tabularFigures,
          ),
          titleLarge: base.titleLarge?.copyWith(color: fg),
          titleMedium: base.titleMedium?.copyWith(color: fg),
          titleSmall: base.titleSmall?.copyWith(color: fg),
          bodyLarge: base.bodyLarge?.copyWith(
            color: fg,
            fontFeatures: _tabularFigures,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            color: fg,
            fontFeatures: _tabularFigures,
          ),
          bodySmall: base.bodySmall?.copyWith(
            color: muted,
            fontFeatures: _tabularFigures,
          ),
          labelLarge: base.labelLarge?.copyWith(color: fg),
          labelMedium: base.labelMedium?.copyWith(color: muted),
          labelSmall: base.labelSmall?.copyWith(color: muted),
        );
  }
}
