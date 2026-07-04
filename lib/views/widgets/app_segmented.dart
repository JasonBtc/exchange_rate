import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// An iOS-style segmented control matching the design spec's `.segmented`
/// (a `--fg-soft` track with a white `--surface` pill under the active
/// segment). Use for compact single-choice rows like 刷新频率.
///
/// Generic over the option value [T] so callers keep their own typed state.
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.compact = false,
  });

  /// The selectable values, laid out as equal-width columns.
  final List<T> options;

  /// The currently active value.
  final T selected;

  /// Renders the label for each option.
  final String Function(T value) labelOf;

  final ValueChanged<T> onChanged;

  /// Uses the smaller 12px label size (`.segmented.compact`).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.fgSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _Segment(
                label: labelOf(option),
                active: option == selected,
                compact: compact,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      // The 6px design gap becomes 3px of padding on each side.
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: active ? colors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        // The active pill sits on a hairline shadow (`box-shadow` in CSS).
        elevation: active ? 1 : 0,
        shadowColor: colors.border,
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          child: Container(
            height: 36,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? colors.fg : colors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
