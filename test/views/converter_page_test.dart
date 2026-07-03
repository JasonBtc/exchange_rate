import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:exchange_rate/controllers/converter_controller.dart';
import 'package:exchange_rate/controllers/settings_controller.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';
import 'package:exchange_rate/core/api_client.dart';
import 'package:exchange_rate/views/converter/converter_page.dart';

class _StubApi extends ApiClient {
  @override
  Future<Map<String, dynamic>> getLatest(String base) async => {
        'result': 'success',
        'base_code': 'USD',
        'time_last_update_unix':
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'rates': {'USD': 1, 'CNY': 7.26},
      };
}

class _Mem implements RateStorage {
  final box = <String, Map<String, dynamic>>{};
  @override
  Map<String, dynamic>? read(String k) => box[k];
  @override
  Future<void> write(String k, Map<String, dynamic> v) async => box[k] = v;
}

class _MemSettingsStorage implements SettingsStorage {
  final Map<String, Object?> box = {};
  @override
  Object? read(String key) => box[key];
  @override
  Future<void> write(String key, Object value) async => box[key] = value;
}

void main() {
  setUpAll(() {
    Get.testMode = true;
  });

  testWidgets('显示结果数值', (tester) async {
    final repo = RateRepository(api: _StubApi(), storage: _Mem());
    Get.put(SettingsController(storage: _MemSettingsStorage()));
    final c = Get.put(ConverterController(repo: repo));
    await c.load();
    c.setAmount('726');

    await tester.pumpWidget(const GetMaterialApp(home: ConverterPage()));
    await tester.pump();

    expect(find.textContaining('100'), findsWidgets); // 726 CNY ≈ 100 USD
    Get.reset();
  });
}
