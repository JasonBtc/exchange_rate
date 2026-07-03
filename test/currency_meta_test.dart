import 'package:flutter_test/flutter_test.dart';

import 'package:exchange_rate/models/currency.dart';
import 'package:exchange_rate/core/currency_meta.dart';
import 'package:exchange_rate/core/constants.dart';

void main() {
  group('Currency', () {
    test('holds the four required fields', () {
      const c = Currency(
        code: 'CNY',
        cnName: '人民币',
        symbol: '¥',
        flag: '🇨🇳',
      );
      expect(c.code, 'CNY');
      expect(c.cnName, '人民币');
      expect(c.symbol, '¥');
      expect(c.flag, '🇨🇳');
    });

    test('equality and hashCode are based on code only', () {
      const a = Currency(code: 'USD', cnName: '美元', symbol: r'$', flag: '🇺🇸');
      const b = Currency(code: 'USD', cnName: 'X', symbol: 'Y', flag: 'Z');
      const c = Currency(code: 'EUR', cnName: '欧元', symbol: '€', flag: '🇪🇺');

      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('kCurrencyMeta', () {
    test('contains every default currency', () {
      for (final code in kDefaultCurrencies) {
        expect(kCurrencyMeta.containsKey(code), isTrue,
            reason: 'meta missing $code');
        expect(kCurrencyMeta[code]!.code, code);
      }
    });

    test('entries have non-empty Chinese name, symbol and flag', () {
      for (final entry in kCurrencyMeta.entries) {
        final v = entry.value;
        expect(v.cnName, isNotEmpty, reason: '${entry.key} cnName empty');
        expect(v.symbol, isNotEmpty, reason: '${entry.key} symbol empty');
        expect(v.flag, isNotEmpty, reason: '${entry.key} flag empty');
      }
    });

    test('CNY entry matches the spec exactly', () {
      final cny = kCurrencyMeta['CNY']!;
      expect(cny.code, 'CNY');
      expect(cny.cnName, '人民币');
      expect(cny.symbol, '¥');
      expect(cny.flag, '🇨🇳');
    });
  });

  group('currencyOf', () {
    test('returns the meta entry for a known code', () {
      final usd = currencyOf('USD');
      expect(usd.code, 'USD');
      expect(usd.cnName, '美元');
      expect(usd, same(kCurrencyMeta['USD']));
    });

    test('returns a code-only fallback for an unknown code', () {
      final xyz = currencyOf('XYZ');
      expect(xyz.code, 'XYZ');
      expect(xyz.cnName, 'XYZ');
      expect(xyz.symbol, 'XYZ');
      expect(xyz.flag, '🏳️');
    });
  });

  group('constants', () {
    test('ApiConst exposes base URL and timeout', () {
      expect(ApiConst.base, 'https://open.er-api.com/v6/latest');
      expect(ApiConst.timeout, const Duration(seconds: 15));
    });

    test('CacheKey exposes the storage keys', () {
      expect(CacheKey.rateTable, 'rate_table');
      expect(CacheKey.themeMode, 'theme_mode');
      expect(CacheKey.decimals, 'decimals');
    });

    test('default base and target are CNY and USD', () {
      expect(kDefaultBase, 'CNY');
      expect(kDefaultTarget, 'USD');
    });

    test('kDefaultCurrencies is the exact 10-code list from the brief', () {
      expect(kDefaultCurrencies, const [
        'CNY',
        'USD',
        'EUR',
        'JPY',
        'GBP',
        'AUD',
        'KRW',
        'HKD',
        'CAD',
        'SGD',
      ]);
    });
  });
}
