import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/rates_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_translations.dart';
import '../../core/currency_flag.dart';
import '../widgets/app_panel.dart';
import '../widgets/page_header.dart';

class RatesPage extends StatelessWidget {
  const RatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RatesController>();
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(
              title: 'rates_title'.tr,
              helper: 'rates_helper'.tr,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: _SearchField(onChanged: (v) => c.search.value = v),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => c.load(forceRefresh: true),
                child: Obx(() {
                  final rows = c.rows;
                  if (c.isLoading.value && rows.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (rows.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Text(
                            'no_match'.tr,
                            style: TextStyle(color: colors.muted),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 120),
                    itemCount: rows.length,
                    itemBuilder: (_, i) {
                      final row = rows[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppPanel(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              currencyFlagCircle(context, row.currency.code,
                                  size: 38),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${row.currency.nameFor(currentLocaleKey)} ${row.currency.code}',
                                      style: TextStyle(
                                        color: colors.fg,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '1 ${row.currency.code} ≈ ${row.rate.toStringAsFixed(4)} ${c.quote.value}',
                                      style: TextStyle(
                                        color: colors.muted,
                                        fontSize: 12,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      onChanged: onChanged,
      style: TextStyle(color: colors.fg),
      decoration: InputDecoration(
        hintText: 'rates_search_hint'.tr,
        hintStyle: TextStyle(color: colors.muted),
        prefixIcon: Icon(Icons.search, color: colors.muted),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
    );
  }
}
