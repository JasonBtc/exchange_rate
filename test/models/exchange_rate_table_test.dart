import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate/models/exchange_rate_table.dart';

void main() {
  final table = ExchangeRateTable(
    base: 'USD',
    usdRates: {'USD': 1.0, 'CNY': 7.26, 'EUR': 0.933},
    updatedAt: DateTime(2026, 7, 3, 10),
  );

  test('rate 计算交叉汇率 CNY->USD', () {
    expect(table.rate('CNY', 'USD'), closeTo(1 / 7.26, 1e-6));
  });

  test('rate USD->CNY 等于牌价', () {
    expect(table.rate('USD', 'CNY'), closeTo(7.26, 1e-6));
  });

  test('convert 金额换算', () {
    expect(table.convert(100, 'CNY', 'USD'), closeTo(100 / 7.26, 1e-6));
  });

  test('未知币种返回 null', () {
    expect(table.rate('CNY', 'XXX'), isNull);
  });

  test('fromApi 解析 rates 与时间', () {
    final t = ExchangeRateTable.fromApi({
      'result': 'success',
      'base_code': 'USD',
      'time_last_update_unix': 1751500800,
      'rates': {'USD': 1, 'CNY': 7.26},
    });
    expect(t.base, 'USD');
    expect(t.usdRates['CNY'], 7.26);
  });

  test('toJson/fromJson 往返一致', () {
    final j = table.toJson();
    final back = ExchangeRateTable.fromJson(j);
    expect(back.usdRates['CNY'], 7.26);
    expect(back.updatedAt, table.updatedAt);
  });

  test('isFromToday 同天判断', () {
    expect(table.isFromToday(DateTime(2026, 7, 3, 23)), isTrue);
    expect(table.isFromToday(DateTime(2026, 7, 4, 1)), isFalse);
  });
}
