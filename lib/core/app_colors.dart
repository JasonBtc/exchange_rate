import 'package:flutter/material.dart';

/// Semantic design tokens from `汇率设计/css/app.css`, exposed as a
/// [ThemeExtension] so widgets can read them via
/// `Theme.of(context).extension<AppColors>()!` and stay correct across
/// light/dark mode.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.border,
    required this.accent,
    required this.accentSoft,
    required this.positive,
    required this.fgSoft,
    required this.converterBg,
    required this.onConverter,
    required this.onConverterMuted,
  });

  /// Page background (`--bg`).
  final Color bg;

  /// Card / panel surface (`--surface`).
  final Color surface;

  /// Primary foreground text (`--fg`).
  final Color fg;

  /// Secondary / helper text (`--muted`).
  final Color muted;

  /// Hairline borders (`--border`).
  final Color border;

  /// Brand accent (`--accent`).
  final Color accent;

  /// 12% accent wash used for active rows / chips (`--accent-soft`).
  final Color accentSoft;

  /// Positive / up movement (`--positive`).
  final Color positive;

  /// 6% foreground wash used for segmented tracks (`--fg-soft`).
  final Color fgSoft;

  /// Dark converter panel background (`.converter` uses `--fg`).
  final Color converterBg;

  /// Text on the converter panel.
  final Color onConverter;

  /// Muted text on the converter panel.
  final Color onConverterMuted;

  static const light = AppColors(
    bg: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    fg: Color(0xFF1B1F26),
    muted: Color(0xFF6B7280),
    border: Color(0xFFE5E8EC),
    accent: Color(0xFF2F6BFF),
    accentSoft: Color(0x1F2F6BFF),
    positive: Color(0xFF12A150),
    fgSoft: Color(0x0F1B1F26),
    converterBg: Color(0xFF1B1F26),
    onConverter: Color(0xFFFFFFFF),
    onConverterMuted: Color(0xA3FFFFFF),
  );

  static const dark = AppColors(
    bg: Color(0xFF14181F),
    surface: Color(0xFF1E232B),
    fg: Color(0xFFF2F4F7),
    muted: Color(0xFF9AA3AE),
    border: Color(0xFF2C333D),
    accent: Color(0xFF2F6BFF),
    accentSoft: Color(0x2E2F6BFF),
    positive: Color(0xFF12A150),
    fgSoft: Color(0x14FFFFFF),
    converterBg: Color(0xFF11151C),
    onConverter: Color(0xFFF2F4F7),
    onConverterMuted: Color(0xA3F2F4F7),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? fg,
    Color? muted,
    Color? border,
    Color? accent,
    Color? accentSoft,
    Color? positive,
    Color? fgSoft,
    Color? converterBg,
    Color? onConverter,
    Color? onConverterMuted,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      fg: fg ?? this.fg,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      positive: positive ?? this.positive,
      fgSoft: fgSoft ?? this.fgSoft,
      converterBg: converterBg ?? this.converterBg,
      onConverter: onConverter ?? this.onConverter,
      onConverterMuted: onConverterMuted ?? this.onConverterMuted,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      fgSoft: Color.lerp(fgSoft, other.fgSoft, t)!,
      converterBg: Color.lerp(converterBg, other.converterBg, t)!,
      onConverter: Color.lerp(onConverter, other.onConverter, t)!,
      onConverterMuted: Color.lerp(onConverterMuted, other.onConverterMuted, t)!,
    );
  }
}

/// Convenience accessor: `context.colors.accent`.
extension AppColorsX on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
