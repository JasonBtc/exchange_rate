import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/app_translations.dart';
import '../core/constants.dart';

abstract class SettingsStorage {
  Object? read(String key);
  Future<void> write(String key, Object value);
}

class GetStorageSettingsStorage implements SettingsStorage {
  final GetStorage _box;
  GetStorageSettingsStorage([GetStorage? box]) : _box = box ?? GetStorage();

  @override
  Object? read(String key) => _box.read(key);

  @override
  Future<void> write(String key, Object value) => _box.write(key, value);
}

class SettingsController extends GetxController {
  final SettingsStorage storage;
  SettingsController({SettingsStorage? storage})
      : storage = storage ?? GetStorageSettingsStorage();

  final isDark = false.obs;
  final decimals = 2.obs;

  /// Auto-refresh interval in minutes. `0` means manual (no auto refresh),
  /// matching the design's 手动 / 15 分钟 / 1 小时 segmented control.
  final refreshMinutes = 15.obs;

  /// Interval options offered by the 刷新频率 segmented control.
  static const List<int> refreshOptions = [0, 15, 60];

  /// Active UI language key (`zh_CN` / `en_US` / `ja_JP`), persisted and
  /// applied via `Get.updateLocale` on change.
  final localeKey = kDefaultLocaleKey.obs;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void _restore() {
    final t = storage.read(CacheKey.themeMode);
    if (t is bool) isDark.value = t;
    final d = storage.read(CacheKey.decimals);
    if (d is int) decimals.value = d;
    final r = storage.read(CacheKey.refreshMinutes);
    if (r is int && refreshOptions.contains(r)) refreshMinutes.value = r;
    final l = storage.read(CacheKey.localeKey);
    if (l is String && kSupportedLocales.any((e) => e.key == l)) {
      localeKey.value = l;
    }
  }

  /// The [Locale] to hand `GetMaterialApp` at startup, derived from the
  /// restored [localeKey].
  Locale get startLocale => appLocaleOf(localeKey.value).locale;

  void toggleTheme(bool value) {
    isDark.value = value;
    storage.write(CacheKey.themeMode, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void setDecimals(int d) {
    decimals.value = d;
    storage.write(CacheKey.decimals, d);
  }

  void setRefreshMinutes(int m) {
    if (!refreshOptions.contains(m)) return;
    refreshMinutes.value = m;
    storage.write(CacheKey.refreshMinutes, m);
  }

  /// Switches the UI language: persists the key and applies it live via
  /// `Get.updateLocale` so every `.tr` string rebuilds.
  void setLocale(String key) {
    final loc = appLocaleOf(key);
    if (loc.key == localeKey.value) return;
    localeKey.value = loc.key;
    storage.write(CacheKey.localeKey, loc.key);
    Get.updateLocale(loc.locale);
  }
}
