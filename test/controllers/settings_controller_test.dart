import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:exchange_rate/controllers/settings_controller.dart';

class _MemStorage implements SettingsStorage {
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

  test('默认值：isDark=false, decimals=2', () {
    final s = _MemStorage();
    final c = SettingsController(storage: s);
    c.onInit();
    expect(c.isDark.value, isFalse);
    expect(c.decimals.value, 2);
  });

  test('onInit 从存储读回主题与精度', () {
    final s = _MemStorage();
    s.box['theme_mode'] = true;
    s.box['decimals'] = 4;
    final c = SettingsController(storage: s);
    c.onInit();
    expect(c.isDark.value, isTrue);
    expect(c.decimals.value, 4);
  });

  test('toggleTheme 写入存储并更新 isDark', () {
    final s = _MemStorage();
    final c = SettingsController(storage: s);
    c.onInit();
    c.toggleTheme(true);
    expect(c.isDark.value, isTrue);
    expect(s.box['theme_mode'], isTrue);
  });

  test('setDecimals 写入存储并更新 decimals', () {
    final s = _MemStorage();
    final c = SettingsController(storage: s);
    c.onInit();
    c.setDecimals(6);
    expect(c.decimals.value, 6);
    expect(s.box['decimals'], 6);
  });
}
