import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// A rounded card matching the design spec's `.panel` (surface fill, 1px
/// hairline border, 22px radius). Use for grouped content on the page
/// background.
class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Overrides the panel fill (defaults to the surface token).
  final Color? color;

  /// Overrides the hairline border (defaults to the border token).
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor ?? colors.border),
      ),
      child: child,
    );
  }
}

/// A small muted section label matching `.field-label`.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? context.colors.muted,
        fontSize: 13,
        height: 1.2,
      ),
    );
  }
}
