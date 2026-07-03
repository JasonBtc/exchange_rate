import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate/controllers/rates_controller.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';
import 'package:exchange_rate/core/api_client.dart';

class _StubApi extends ApiClient {
  @override
  Future<Map<String, dynamic>> getLatest(String base) async => {
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_unix':
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'rates': {'USD': 1, 'CNY': 7.26, 'EUR': 0.93, 'JPY': 157.0},
      };
}

class _MemStorage implements RateStorage {
  final Map<String, Map<String, dynamic>> box = {};
  @override
  Map<String, dynamic>? read(String key) => box[key];
  @override
  Future<void> write(String key, Map<String, dynamic> value) async =>
      box[key] = value;
}

void main() {
  late RatesController c;
  setUp(() {
    c = RatesController(
      repo: RateRepository(api: _StubApi(), storage: _MemStorage()),
    );
  });

  test('rows 生成非基准币种行且换算为 CNY', () async {
    await c.load();
    final usd = c.rows.firstWhere((r) => r.currency.code == 'USD');
    expect(usd.rate, closeTo(7.26, 0.01)); // 1 USD ≈ 7.26 CNY
    expect(c.rows.any((r) => r.currency.code == 'CNY'), isFalse);
  });

  test('search 过滤', () async {
    await c.load();
    c.search.value = 'USD';
    expect(c.rows.length, 1);
    expect(c.rows.first.currency.code, 'USD');
  });
}
