import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/rates_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_translations.dart';
import '../widgets/app_panel.dart';
import '../widgets/app_segmented.dart';
import '../widgets/page_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    final rates = Get.find<RatesController>();
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
                title: 'settings_title'.tr, helper: 'settings_helper'.tr),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 120),
                children: [
                  AppPanel(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4),
                    child: Obx(() => SwitchListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text('dark_theme'.tr),
                          subtitle: Text('dark_theme_sub'.tr),
                          activeThumbColor: colors.accent,
                          value: c.isDark.value,
                          onChanged: c.toggleTheme,
                        )),
                  ),
                  const SizedBox(height: 14),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FieldLabel('precision'.tr),
                        const SizedBox(height: 12),
                        Obx(() => SegmentedButton<int>(
                              segments: [
                                for (final d in const [2, 4, 6])
                                  ButtonSegment(
                                    value: d,
                                    label: Text(
                                        'digits'.trParams({'n': '$d'})),
                                  ),
                              ],
                              selected: {c.decimals.value},
                              onSelectionChanged: (s) =>
                                  c.setDecimals(s.first),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LanguagePanel(controller: c),
                  const SizedBox(height: 14),
                  _RefreshRatePanel(controller: c, rates: rates),
                  const SizedBox(height: 14),
                  _DataSourcePanel(rates: rates),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 刷新频率: a compact segmented control (手动 / 15 分钟 / 1 小时) plus a
/// sync card previewing the next automatic refresh, matching the design's
/// `.segmented.compact` + `.sync-card`.
class _RefreshRatePanel extends StatelessWidget {
  const _RefreshRatePanel({required this.controller, required this.rates});

  final SettingsController controller;
  final RatesController rates;

  String _labelFor(int minutes) {
    switch (minutes) {
      case 0:
        return 'refresh_manual'.tr;
      case 60:
        return 'refresh_hour'.tr;
      default:
        return 'refresh_min'.trParams({'n': '$minutes'});
    }
  }

  /// The refresh cadence shown on the sync card. Distinct wording from the
  /// segmented options ("每…") so it doesn't collide with them in the widget
  /// tree, and — unlike the old wall-clock "next refresh at HH:MM" — it never
  /// goes stale as time passes since it only depends on the interval.
  String _intervalLabel(int minutes) {
    if (minutes >= 60) return 'refresh_interval_hour'.tr;
    return 'refresh_interval_min'.trParams({'n': '$minutes'});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel('refresh_freq'.tr),
          const SizedBox(height: 12),
          Obx(() => AppSegmented<int>(
                compact: true,
                options: SettingsController.refreshOptions,
                selected: controller.refreshMinutes.value,
                labelOf: _labelFor,
                onChanged: controller.setRefreshMinutes,
              )),
          const SizedBox(height: 12),
          Obx(() {
            final manual = controller.refreshMinutes.value == 0;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.fgSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'next_auto_refresh'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.fg,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'refresh_wifi_note'.tr,
                          style:
                              TextStyle(fontSize: 13, color: colors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    manual
                        ? 'refresh_off'.tr
                        : _intervalLabel(controller.refreshMinutes.value),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.fg,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 数据来源: a two-cell grid (主汇率源 / 离线数据) above a full-width
/// 立即同步汇率 action, matching the design's `.source-grid` + `.wide-action`.
class _DataSourcePanel extends StatelessWidget {
  const _DataSourcePanel({required this.rates});

  final RatesController rates;

  String _offlineLabel(DateTime? updatedAt) {
    if (updatedAt == null) return 'ago_none'.tr;
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inMinutes < 1) return 'ago_just'.tr;
    if (diff.inMinutes < 60) {
      return 'ago_min'.trParams({'n': '${diff.inMinutes}'});
    }
    if (diff.inHours < 24) {
      return 'ago_hour'.trParams({'n': '${diff.inHours}'});
    }
    return 'ago_day'.trParams({'n': '${diff.inDays}'});
  }

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel('data_source'.tr),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SourceCell(
                    label: 'primary_source'.tr,
                    value: 'open.er-api.com',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => _SourceCell(
                        label: 'offline_data'.tr,
                        value: _offlineLabel(rates.table.value?.updatedAt),
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => _WideAction(
                loading: rates.isLoading.value,
                onTap: () => rates.load(forceRefresh: true),
              )),
        ],
      ),
    );
  }
}

/// 语言: a segmented control switching the UI language live between
/// 中文 / English / 日本語 via `SettingsController.setLocale`.
class _LanguagePanel extends StatelessWidget {
  const _LanguagePanel({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel('language'.tr),
          const SizedBox(height: 12),
          Obx(() => AppSegmented<String>(
                options: kSupportedLocales.map((l) => l.key).toList(),
                selected: controller.localeKey.value,
                labelOf: (key) => appLocaleOf(key).nativeName,
                onChanged: controller.setLocale,
              )),
        ],
      ),
    );
  }
}

/// A single labelled cell inside the 数据来源 grid (`.source-grid div`).
class _SourceCell extends StatelessWidget {
  const _SourceCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.fgSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: colors.muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: colors.fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// The full-width 立即同步汇率 button (`.wide-action`).
class _WideAction extends StatelessWidget {
  const _WideAction({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        onPressed: loading ? null : onTap,
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colors.surface),
                ),
              )
            : Text('sync_now'.tr),
      ),
    );
  }
}
