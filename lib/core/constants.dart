class ApiConst {
  static const String base = 'https://open.er-api.com/v6/latest';
  static const Duration timeout = Duration(seconds: 15);
}

class CacheKey {
  static const String rateTable = 'rate_table';
  static const String themeMode = 'theme_mode';
  static const String decimals = 'decimals';
}

const String kDefaultBase = 'CNY';
const String kDefaultTarget = 'USD';
const List<String> kDefaultCurrencies = [
  'CNY', 'USD', 'EUR', 'JPY', 'GBP', 'AUD', 'KRW', 'HKD', 'CAD', 'SGD',
];
