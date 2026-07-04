import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Renders a currency's country flag as a vector image (SVG), independent of
/// the platform emoji font. Falls back to a placeholder for unknown codes.
///
/// Flags use a 3:2 aspect ratio with slightly rounded corners, matching the
/// design's card radius language.
Widget currencyFlag(String code, {double width = 32}) {
  return CountryFlag.fromCurrencyCode(
    code,
    theme: ImageTheme(
      width: width,
      height: width * 2 / 3,
      shape: const RoundedRectangle(4),
    ),
  );
}

/// Circular flag matching the design spec's `.flag` token (a bordered round
/// avatar). [size] is the diameter. The SVG is cropped to a circle by the
/// package; we wrap it in a bordered container to match the spec's hairline
/// ring and give unknown codes a neutral filled circle.
Widget currencyFlagCircle(
  BuildContext context,
  String code, {
  double size = 34,
}) {
  final border = context.colors.border;
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: border),
      color: context.colors.fgSoft,
    ),
    clipBehavior: Clip.antiAlias,
    child: CountryFlag.fromCurrencyCode(
      code,
      theme: ImageTheme(
        width: size,
        height: size,
        shape: const Circle(),
      ),
    ),
  );
}
