import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/converter_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_translations.dart';
import '../../core/currency_flag.dart';
import '../../core/currency_meta.dart';
import '../widgets/app_panel.dart';
import '../widgets/page_header.dart';
import 'widgets/currency_picker.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  late final ConverterController c;
  late final SettingsController settings;
  late final TextEditingController amountCtrl;
  Worker? _amountWorker;

  String _amountToText(double v) => v == 0 ? '' : v.toString();

  @override
  void initState() {
    super.initState();
    c = Get.find<ConverterController>();
    settings = Get.find<SettingsController>();
    amountCtrl = TextEditingController(text: _amountToText(c.amount.value));
    _amountWorker = ever<double>(c.amount, (v) {
      final next = _amountToText(v);
      if (amountCtrl.text != next) {
        amountCtrl.text = next;
      }
    });
  }

  @override
  void dispose() {
    _amountWorker?.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBase() async {
    final r = await showCurrencyPicker(context,
        selected: c.base.value, codes: c.availableCodes);
    if (r != null) c.setBase(r);
  }

  Future<void> _pickTarget() async {
    final r = await showCurrencyPicker(context,
        selected: c.target.value, codes: c.availableCodes);
    if (r != null) c.setTarget(r);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => c.load(forceRefresh: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 120),
            children: [
              Obx(() {
                final updated = c.table.value?.updatedAt;
                return PageHeader(
                  title: 'converter_title'.tr,
                  helper: updated == null
                      ? 'converter_loading_helper'.tr
                      : 'converter_source_helper'
                          .trParams({'ago': _ago(updated)}),
                );
              }),
              const SizedBox(height: 14),
              _converterCard(colors),
              const SizedBox(height: 14),
              Obx(() {
                if (c.error.value == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AppPanel(
                    borderColor: colors.danger.withValues(alpha: 0.4),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: colors.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'load_failed'
                                  .trParams({'msg': '${c.error.value}'}),
                              style: TextStyle(color: colors.danger)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Obx(() => _unitRatePanel(colors)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _converterCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.converterBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reactive leaves are wrapped individually so a keystroke only
          // rebuilds the affected label/result, not the whole card (and never
          // the TextField, which keeps its own state via amountCtrl).
          Obx(() => FieldLabel(
              'input_amount'.trParams(
                  {'cur': currencyOf(c.base.value).nameFor(currentLocaleKey)}),
              color: colors.onConverterMuted)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: colors.onConverter,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  cursorColor: colors.accent,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                  onChanged: c.setAmount,
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => _chip(c.base.value, colors, _pickBase)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
                height: 1, color: colors.onConverter.withValues(alpha: 0.18)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                        'convert_to'.trParams({
                          'cur': currencyOf(c.target.value)
                              .nameFor(currentLocaleKey)
                        }),
                        style: TextStyle(color: colors.onConverterMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                    const SizedBox(height: 4),
                    // Long results (large amounts / 6-digit precision) scale
                    // down to fit one line instead of wrapping or overflowing.
                    Obx(() => FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            c.result.toStringAsFixed(settings.decimals.value),
                            maxLines: 1,
                            style: TextStyle(
                              color: colors.onConverter,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => _chip(c.target.value, colors, _pickTarget)),
            ],
          ),
        ],
      ),
    );
  }

  /// Rounded currency chip on the dark converter panel (`.currency-chip`).
  Widget _chip(String code, AppColors colors, VoidCallback onTap) {
    return Material(
      color: colors.onConverter.withValues(alpha: 0.10),
      shape: StadiumBorder(
        side: BorderSide(color: colors.onConverter.withValues(alpha: 0.26)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              currencyFlag(code, width: 22),
              const SizedBox(width: 8),
              Text(code,
                  style: TextStyle(
                      color: colors.onConverter,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 2),
              Icon(Icons.expand_more,
                  size: 18, color: colors.onConverterMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitRatePanel(AppColors colors) {
    final base = c.base.value;
    final target = c.target.value;
    final r = c.unitRate;
    final loading = c.table.value == null;
    return AppPanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldLabel('unit_rate_label'.tr),
                const SizedBox(height: 6),
                Text(
                  '1 $base ≈ ${r.toStringAsFixed(4)} $target',
                  style: TextStyle(
                    color: colors.fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loading
                      ? 'loading'.tr
                      : 'updated_at'
                          .trParams({'ago': _ago(c.table.value!.updatedAt)}),
                  style: TextStyle(color: colors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: c.swap,
            icon: const Icon(Icons.swap_vert, size: 18),
            label: Text('swap'.tr),
          ),
        ],
      ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'ago_just_updated'.tr;
    if (d.inMinutes < 60) return 'ago_min_updated'.trParams({'n': '${d.inMinutes}'});
    if (d.inHours < 24) return 'ago_hour_updated'.trParams({'n': '${d.inHours}'});
    return 'ago_day_updated'.trParams({'n': '${d.inDays}'});
  }
}
