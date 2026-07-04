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

  // Brand & semantic tokens
  static const Color accent = Color(0xFF2F6BFF);
  static const Color positive = Color(0xFF12A150);

  // Light surface tokens
  static const Color _lightBg = Color(0xFFF7F8FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightFg = Color(0xFF1B1F26);
  static const Color _lightMuted = Color(0xFF6B7280);
  static const Color _lightBorder = Color(0xFFE5E8EC);

  // Dark surface tokens
  static const Color _darkBg = Color(0xFF14181F);
  static const Color _darkSurface = Color(0xFF1E232B);
  static const Color _darkFg = Color(0xFFF2F4F7);
  static const Color _darkMuted = Color(0xFF9AA3AE);
  static const Color _darkBorder = Color(0xFF2C333D);

  static const double _cardRadius = 20;

  static const List<FontFeature> _tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: accent,
      surface: _lightSurface,
      onSurface: _lightFg,
      outline: _lightBorder,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: _lightBg,
    );

    return base.copyWith(
      textTheme: _applyTabularFigures(base.textTheme, _lightFg, _lightMuted),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: _lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: _lightBorder, thickness: 1),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBg,
        foregroundColor: _lightFg,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      extensions: const [AppColors.light],
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accent,
      surface: _darkSurface,
      onSurface: _darkFg,
      outline: _darkBorder,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: _darkBg,
    );

    return base.copyWith(
      textTheme: _applyTabularFigures(base.textTheme, _darkFg, _darkMuted),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: _darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: _darkBorder, thickness: 1),
      extensions: const [AppColors.dark],
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBg,
        foregroundColor: _darkFg,
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
