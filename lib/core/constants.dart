class ApiConst {
  static const String base = 'https://open.er-api.com/v6/latest';
  static const Duration timeout = Duration(seconds: 15);
}

class CacheKey {
  static const String rateTable = 'rate_table';
  static const String themeMode = 'theme_mode';
  static const String decimals = 'decimals';
  static const String refreshMinutes = 'refresh_minutes';
  static const String localeKey = 'locale_key';
}

const String kDefaultBase = 'CNY';
const String kDefaultTarget = 'USD';

/// Currencies pinned to the top of rate lists and pickers, in priority order.
/// Any other currency returned by the API is shown afterwards, sorted
/// alphabetically by code. This is an ordering hint only — the full list of
/// selectable currencies comes from the live rate table.
const List<String> kPopularCurrencies = [
  'CNY', 'USD', 'EUR', 'JPY', 'GBP', 'HKD', 'AUD', 'KRW', 'CAD', 'SGD',
  'THB', 'TWD', 'MYR', 'CHF', 'NZD', 'RUB', 'INR', 'MOP',
];

/// Backwards-compatible alias retained for existing references/tests.
const List<String> kDefaultCurrencies = kPopularCurrencies;
