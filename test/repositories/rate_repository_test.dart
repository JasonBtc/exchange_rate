import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate/core/api_client.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';

class _FakeApi extends ApiClient {
  @override
  Future<Map<String, dynamic>> getLatest(String base) async => {
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_unix': 1751500800,
        'rates': {'USD': 1, 'CNY': 7.26, 'EUR': 0.93},
      };
}

class _FakeStorage implements RateStorage {
  final Map<String, Map<String, dynamic>> box = {};
  @override
  Map<String, dynamic>? read(String key) => box[key];
  @override
  Future<void> write(String key, Map<String, dynamic> value) async =>
      box[key] = value;
}

class _CountingApi extends ApiClient {
  final void Function() onCall;
  _CountingApi(this.onCall);
  @override
  Future<Map<String, dynamic>> getLatest(String base) async {
    onCall();
    return {
      'result': 'success',
      'base_code': 'USD',
      'time_last_update_unix': 1751500800,
      'rates': {'USD': 1, 'CNY': 7.26},
    };
  }
}

void main() {
  test('fetchFresh 拉取并写入缓存', () async {
    final storage = _FakeStorage();
    final repo = RateRepository(api: _FakeApi(), storage: storage);
    final table = await repo.fetchFresh();
    expect(table.usdRates['CNY'], 7.26);
    expect(storage.box.containsKey('rate_table'), isTrue);
  });

  test('getRates 命中当天缓存则不请求网络', () async {
    final storage = _FakeStorage();
    // 预置今天的缓存
    final today = DateTime.now();
    storage.box['rate_table'] = {
      'base': 'USD',
      'usdRates': {'USD': 1.0, 'CNY': 7.0},
      'updatedAt': today.millisecondsSinceEpoch,
    };
    var apiCalled = false;
    final repo = RateRepository(
      api: _CountingApi(() => apiCalled = true),
      storage: storage,
    );
    final table = await repo.getRates(now: today);
    expect(apiCalled, isFalse);
    expect(table.usdRates['CNY'], 7.0);
  });

  test('getRates 缓存过期则请求网络', () async {
    final storage = _FakeStorage();
    storage.box['rate_table'] = {
      'base': 'USD',
      'usdRates': {'USD': 1.0, 'CNY': 7.0},
      'updatedAt': DateTime(2020, 1, 1).millisecondsSinceEpoch,
    };
    final repo = RateRepository(api: _FakeApi(), storage: storage);
    final table = await repo.getRates(now: DateTime.now());
    expect(table.usdRates['CNY'], 7.26); // 来自网络
  });
}
