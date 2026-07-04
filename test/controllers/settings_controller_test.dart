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

  test('默认语言为 zh_CN', () {
    final c = SettingsController(storage: _MemStorage());
    c.onInit();
    expect(c.localeKey.value, 'zh_CN');
  });

  test('onInit 从存储读回语言', () {
    final s = _MemStorage();
    s.box['locale_key'] = 'ja_JP';
    final c = SettingsController(storage: s);
    c.onInit();
    expect(c.localeKey.value, 'ja_JP');
  });

  test('setLocale 写入存储并更新 localeKey', () {
    final s = _MemStorage();
    final c = SettingsController(storage: s);
    c.onInit();
    c.setLocale('en_US');
    expect(c.localeKey.value, 'en_US');
    expect(s.box['locale_key'], 'en_US');
  });

  test('setLocale 忽略未知语言', () {
    final s = _MemStorage();
    final c = SettingsController(storage: s);
    c.onInit();
    c.setLocale('xx_YY');
    // Unknown keys resolve to the default (zh_CN); since that equals the
    // current value, no change is written.
    expect(c.localeKey.value, 'zh_CN');
  });
}
