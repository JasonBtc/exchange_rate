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

void main() {
  test('fetchFresh 拉取并写入缓存', () async {
    final storage = _FakeStorage();
    final repo = RateRepository(api: _FakeApi(), storage: storage);
    final table = await repo.fetchFresh();
    expect(table.usdRates['CNY'], 7.26);
    expect(storage.box.containsKey('rate_table'), isTrue);
  });
}
