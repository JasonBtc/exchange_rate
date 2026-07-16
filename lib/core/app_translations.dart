import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// A supported UI language: its GetX translation key (`languageCode_countryCode`),
/// the matching Flutter [Locale], and the native display name shown in the
/// language switcher (always in its own script, regardless of the active UI
/// language).
class AppLocale {
  const AppLocale(this.key, this.locale, this.nativeName);

  /// GetX translations key, e.g. `zh_CN`.
  final String key;

  /// The Flutter locale passed to `Get.updateLocale`.
  final Locale locale;

  /// Endonym shown in the picker (中文 / English / 日本語).
  final String nativeName;
}

/// The three languages offered in Settings, in display order.
const List<AppLocale> kSupportedLocales = [
  AppLocale('zh_CN', Locale('zh', 'CN'), '中文'),
  AppLocale('en_US', Locale('en', 'US'), 'English'),
  AppLocale('ja_JP', Locale('ja', 'JP'), '日本語'),
];

/// The default/fallback language key.
const String kDefaultLocaleKey = 'zh_CN';

/// Resolves a stored key back to its [AppLocale], falling back to the default.
AppLocale appLocaleOf(String key) => kSupportedLocales.firstWhere(
      (l) => l.key == key,
      orElse: () => kSupportedLocales.first,
    );

/// The active UI language key (`zh_CN` / `en_US` / `ja_JP`) derived from the
/// live `Get.locale`, falling back to the default. Currency names and other
/// locale-aware lookups use this so they follow `Get.updateLocale`.
String get currentLocaleKey {
  final loc = Get.locale;
  if (loc == null) return kDefaultLocaleKey;
  final key = '${loc.languageCode}_${loc.countryCode}';
  return kSupportedLocales.any((l) => l.key == key) ? key : kDefaultLocaleKey;
}

/// GetX translation catalog. Keys are shared across every view; interpolated
/// values use `@name` placeholders resolved with `.trParams`.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => const {
        'zh_CN': _zh,
        'en_US': _en,
        'ja_JP': _ja,
      };
}

const Map<String, String> _zh = {
  // App / tabs
  'app_title': '汇率换算',
  'tab_convert': '换算',
  'tab_rates': '行情',
  'tab_settings': '设置',

  // Converter
  'converter_title': '实时换算',
  'converter_loading_helper': '正在获取最新汇率…',
  'converter_source_helper': '数据来源 open.er-api.com · @ago',
  'load_failed': '数据加载失败：@msg',
  'input_amount': '输入@cur金额',
  'convert_to': '换算为 @cur',
  'unit_rate_label': '参考单位汇率',
  'loading': '加载中…',
  'updated_at': '更新于 @ago',
  'swap': '交换',

  // Relative time (with "更新" suffix, used on the converter)
  'ago_just_updated': '刚刚更新',
  'ago_min_updated': '@n 分钟前更新',
  'ago_hour_updated': '@n 小时前更新',
  'ago_day_updated': '@n 天前更新',

  // Relative time (bare, used for the offline-data cell)
  'ago_just': '刚刚',
  'ago_min': '@n 分钟前',
  'ago_hour': '@n 小时前',
  'ago_day': '@n 天前',
  'ago_none': '暂无',

  // Rates
  'rates_title': '行情',
  'rates_helper': '实时汇率 · 支持全部币种',
  'no_match': '没有匹配的币种',
  'rates_search_hint': '搜索美元、JPY、欧元',

  // Currency picker
  'picker_search_hint': '搜索币种名称或代码',

  // Settings
  'settings_title': '设置',
  'settings_helper': '偏好与数据来源',
  'dark_theme': '深色主题',
  'dark_theme_sub': '适合夜间查价',
  'precision': '换算精度',
  'digits': '@n 位',
  'refresh_freq': '刷新频率',
  'refresh_manual': '手动',
  'refresh_hour': '1 小时',
  'refresh_min': '@n 分钟',
  'refresh_interval_min': '每 @n 分钟',
  'refresh_interval_hour': '每小时',
  'next_auto_refresh': '下一次自动刷新',
  'refresh_wifi_note': 'Wi-Fi 下更新全部常用币种',
  'refresh_off': '已关闭',
  'data_source': '数据来源',
  'primary_source': '主汇率源',
  'offline_data': '离线数据',
  'sync_now': '立即同步汇率',
  'language': '语言',
};

const Map<String, String> _en = {
  // App / tabs
  'app_title': 'Exchange Rate',
  'tab_convert': 'Convert',
  'tab_rates': 'Rates',
  'tab_settings': 'Settings',

  // Converter
  'converter_title': 'Live Convert',
  'converter_loading_helper': 'Fetching latest rates…',
  'converter_source_helper': 'Source open.er-api.com · @ago',
  'load_failed': 'Failed to load: @msg',
  'input_amount': 'Enter @cur amount',
  'convert_to': 'Convert to @cur',
  'unit_rate_label': 'Reference unit rate',
  'loading': 'Loading…',
  'updated_at': 'Updated @ago',
  'swap': 'Swap',

  // Relative time (with suffix)
  'ago_just_updated': 'Just updated',
  'ago_min_updated': '@n min ago',
  'ago_hour_updated': '@n hr ago',
  'ago_day_updated': '@n days ago',

  // Relative time (bare)
  'ago_just': 'Just now',
  'ago_min': '@n min ago',
  'ago_hour': '@n hr ago',
  'ago_day': '@n days ago',
  'ago_none': 'None',

  // Rates
  'rates_title': 'Rates',
  'rates_helper': 'Live rates · all currencies',
  'no_match': 'No matching currency',
  'rates_search_hint': 'Search USD, JPY, EUR',

  // Currency picker
  'picker_search_hint': 'Search name or code',

  // Settings
  'settings_title': 'Settings',
  'settings_helper': 'Preferences & data source',
  'dark_theme': 'Dark theme',
  'dark_theme_sub': 'Easy on the eyes at night',
  'precision': 'Precision',
  'digits': '@n digits',
  'refresh_freq': 'Refresh rate',
  'refresh_manual': 'Manual',
  'refresh_hour': '1 hr',
  'refresh_min': '@n min',
  'refresh_interval_min': 'Every @n min',
  'refresh_interval_hour': 'Hourly',
  'next_auto_refresh': 'Next auto refresh',
  'refresh_wifi_note': 'Updates all favorites on Wi-Fi',
  'refresh_off': 'Off',
  'data_source': 'Data source',
  'primary_source': 'Primary source',
  'offline_data': 'Offline data',
  'sync_now': 'Sync now',
  'language': 'Language',
};

const Map<String, String> _ja = {
  // App / tabs
  'app_title': '為替レート',
  'tab_convert': '換算',
  'tab_rates': 'レート',
  'tab_settings': '設定',

  // Converter
  'converter_title': 'リアルタイム換算',
  'converter_loading_helper': '最新レートを取得中…',
  'converter_source_helper': 'データ元 open.er-api.com · @ago',
  'load_failed': '読み込み失敗：@msg',
  'input_amount': '@curの金額を入力',
  'convert_to': '@curに換算',
  'unit_rate_label': '参考単位レート',
  'loading': '読み込み中…',
  'updated_at': '@ago更新',
  'swap': '交換',

  // Relative time (with suffix)
  'ago_just_updated': 'たった今更新',
  'ago_min_updated': '@n分前に更新',
  'ago_hour_updated': '@n時間前に更新',
  'ago_day_updated': '@n日前に更新',

  // Relative time (bare)
  'ago_just': 'たった今',
  'ago_min': '@n分前',
  'ago_hour': '@n時間前',
  'ago_day': '@n日前',
  'ago_none': 'なし',

  // Rates
  'rates_title': 'レート',
  'rates_helper': 'リアルタイムレート · 全通貨対応',
  'no_match': '一致する通貨がありません',
  'rates_search_hint': 'USD、JPY、EURで検索',

  // Currency picker
  'picker_search_hint': '通貨名またはコードで検索',

  // Settings
  'settings_title': '設定',
  'settings_helper': '設定とデータ元',
  'dark_theme': 'ダークテーマ',
  'dark_theme_sub': '夜間の確認に最適',
  'precision': '換算精度',
  'digits': '@n桁',
  'refresh_freq': '更新頻度',
  'refresh_manual': '手動',
  'refresh_hour': '1時間',
  'refresh_min': '@n分',
  'refresh_interval_min': '@n分ごと',
  'refresh_interval_hour': '1時間ごと',
  'next_auto_refresh': '次回の自動更新',
  'refresh_wifi_note': 'Wi-Fi接続時に全通貨を更新',
  'refresh_off': 'オフ',
  'data_source': 'データ元',
  'primary_source': '主レート元',
  'offline_data': 'オフラインデータ',
  'sync_now': '今すぐ同期',
  'language': '言語',
};
