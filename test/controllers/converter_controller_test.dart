import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate/controllers/converter_controller.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';
import 'package:exchange_rate/core/api_client.dart';

class _StubApi extends ApiClient {
  @override
  Future<Map<String, dynamic>> getLatest(String base) async => {
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_unix':
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'rates': {'USD': 1, 'CNY': 7.26, 'EUR': 0.93},
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
  late ConverterController c;
  setUp(() {
    c = ConverterController(
      repo: RateRepository(api: _StubApi(), storage: _MemStorage()),
    );
  });

  test('load 后可换算 CNY->USD', () async {
    await c.load();
    c.setAmount('726');
    expect(c.result, closeTo(100, 0.01));
  });

  test('swap 交换 base/target', () async {
    await c.load();
    c.swap();
    expect(c.base.value, 'USD');
    expect(c.target.value, 'CNY');
  });

  test('setAmount 非法输入置 0', () async {
    await c.load();
    c.setAmount('abc');
    expect(c.amount.value, 0);
  });
}
