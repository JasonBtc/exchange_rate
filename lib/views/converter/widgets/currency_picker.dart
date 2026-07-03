import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/currency_meta.dart';

Future<String?> showCurrencyPicker(
  BuildContext context, {
  required String selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => ListView(
      shrinkWrap: true,
      children: kDefaultCurrencies.map((code) {
        final cur = currencyOf(code);
        return ListTile(
          leading: Text(cur.flag, style: const TextStyle(fontSize: 24)),
          title: Text('${cur.cnName} $code'),
          trailing: code == selected
              ? const Icon(Icons.check, color: Color(0xFF2F6BFF))
              : null,
          onTap: () => Navigator.pop(ctx, code),
        );
      }).toList(),
    ),
  );
}
