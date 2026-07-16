class ApiConst {
  /// Rate API base URL. Overridable at build time via
  /// `--dart-define=RATE_API_BASE=…` for staging/self-hosted mirrors.
  static const String base = String.fromEnvironment(
    'RATE_API_BASE',
    defaultValue: 'https://open.er-api.com/v6/latest',
  );
  static const Duration timeout = Duration(seconds: 15);

  /// Fallback cache freshness window when a caller doesn't pass an explicit
  /// `maxAge` (i.e. the user picked 手动 refresh). Keeps a cold start from
  /// re-fetching data that's only minutes old.
  static const Duration defaultMaxAge = Duration(hours: 12);

  /// Number of transient-failure retries for a rate fetch, with a short
  /// backoff between attempts.
  static const int maxRetries = 2;
  static const Duration retryBackoff = Duration(milliseconds: 600);
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
