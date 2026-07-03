import '../models/currency.dart';

const Map<String, Currency> kCurrencyMeta = {
  'CNY': Currency(code: 'CNY', cnName: '人民币', symbol: '¥', flag: '🇨🇳'),
  'USD': Currency(code: 'USD', cnName: '美元', symbol: '\$', flag: '🇺🇸'),
  'EUR': Currency(code: 'EUR', cnName: '欧元', symbol: '€', flag: '🇪🇺'),
  'JPY': Currency(code: 'JPY', cnName: '日元', symbol: '¥', flag: '🇯🇵'),
  'GBP': Currency(code: 'GBP', cnName: '英镑', symbol: '£', flag: '🇬🇧'),
  'AUD': Currency(code: 'AUD', cnName: '澳元', symbol: '\$', flag: '🇦🇺'),
  'KRW': Currency(code: 'KRW', cnName: '韩元', symbol: '₩', flag: '🇰🇷'),
  'HKD': Currency(code: 'HKD', cnName: '港币', symbol: '\$', flag: '🇭🇰'),
  'CAD': Currency(code: 'CAD', cnName: '加元', symbol: '\$', flag: '🇨🇦'),
  'SGD': Currency(code: 'SGD', cnName: '新加坡元', symbol: '\$', flag: '🇸🇬'),
};

Currency currencyOf(String code) =>
    kCurrencyMeta[code] ??
    Currency(code: code, cnName: code, symbol: code, flag: '🏳️');
