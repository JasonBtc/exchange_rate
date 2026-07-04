import 'package:flutter_test/flutter_test.dart';

import 'package:exchange_rate/models/currency.dart';
import 'package:exchange_rate/core/currency_meta.dart';
import 'package:exchange_rate/core/constants.dart';

void main() {
  group('Currency', () {
    test('holds the three required fields', () {
      const c = Currency(
        code: 'CNY',
        cnName: '人民币',
        symbol: '¥',
      );
      expect(c.code, 'CNY');
      expect(c.cnName, '人民币');
      expect(c.symbol, '¥');
    });

    test('equality and hashCode are based on code only', () {
      const a = Currency(code: 'USD', cnName: '美元', symbol: r'$');
      const b = Currency(code: 'USD', cnName: 'X', symbol: 'Y');
      const c = Currency(code: 'EUR', cnName: '欧元', symbol: '€');

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

    test('entries have non-empty Chinese name and symbol', () {
      for (final entry in kCurrencyMeta.entries) {
        final v = entry.value;
        expect(v.cnName, isNotEmpty, reason: '${entry.key} cnName empty');
        expect(v.symbol, isNotEmpty, reason: '${entry.key} symbol empty');
      }
    });

    test('CNY entry matches the spec exactly', () {
      final cny = kCurrencyMeta['CNY']!;
      expect(cny.code, 'CNY');
      expect(cny.cnName, '人民币');
      expect(cny.symbol, '¥');
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

    test('kPopularCurrencies is an ordering hint led by CNY and USD', () {
      // The app now shows every currency the live rate table returns;
      // kPopularCurrencies only pins the common ones to the top. It is no
      // longer an exhaustive list, but it must stay CNY-first, USD-second,
      // duplicate-free, and fully covered by the name map.
      expect(kPopularCurrencies[0], 'CNY');
      expect(kPopularCurrencies[1], 'USD');
      expect(kPopularCurrencies.toSet().length, kPopularCurrencies.length,
          reason: 'kPopularCurrencies has duplicate codes');
      for (final code in kPopularCurrencies) {
        expect(kCurrencyMeta.containsKey(code), isTrue,
            reason: 'meta missing popular code $code');
      }
    });

    test('kDefaultCurrencies aliases kPopularCurrencies', () {
      expect(kDefaultCurrencies, same(kPopularCurrencies));
    });
  });
}
