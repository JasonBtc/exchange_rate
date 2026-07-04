import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_translations.dart';
import '../../../core/currency_flag.dart';
import '../../../core/currency_meta.dart';

/// A searchable bottom sheet for choosing a currency from the full set
/// returned by the live rate table (~160 codes). Pass [codes] to constrain
/// the list to the currencies the API currently returns; when omitted it
/// falls back to every currency the app knows a name for.
///
/// Results are ordered common-first (see [sortByPopularity]) and filter live
/// as the user types against both the ISO code and the Chinese name.
Future<String?> showCurrencyPicker(
  BuildContext context, {
  required String selected,
  Iterable<String>? codes,
}) {
  final all = sortByPopularity(codes ?? kCurrencyMeta.keys);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.colors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _CurrencyPickerSheet(all: all, selected: selected),
  );
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({required this.all, required this.selected});

  final List<String> all;
  final String selected;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _query = '';

  List<String> get _filtered {
    final q = _query.trim().toUpperCase();
    if (q.isEmpty) return widget.all;
    return widget.all.where((code) {
      if (code.toUpperCase().contains(q)) return true;
      final cur = currencyOf(code);
      return cur.cnName.toUpperCase().contains(q) ||
          cur.enName.toUpperCase().contains(q) ||
          cur.jaName.toUpperCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filtered = _filtered;
    // Cap the sheet just below full height so the drag handle stays visible.
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'picker_search_hint'.tr,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colors.surface,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: colors.accent, width: 2),
                    ),
                  ),
                ),
              ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('no_match'.tr,
                      style: TextStyle(color: colors.muted)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final code = filtered[i];
                      final cur = currencyOf(code);
                      final isSel = code == widget.selected;
                      return ListTile(
                        leading: currencyFlagCircle(context, code, size: 36),
                        title: Text(cur.nameFor(currentLocaleKey)),
                        subtitle: Text(code,
                            style: TextStyle(color: colors.muted)),
                        trailing: isSel
                            ? Icon(Icons.check, color: colors.accent)
                            : null,
                        onTap: () => Navigator.pop(context, code),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
