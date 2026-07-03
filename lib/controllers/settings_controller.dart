import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  }

  void toggleTheme(bool value) {
    isDark.value = value;
    storage.write(CacheKey.themeMode, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void setDecimals(int d) {
    decimals.value = d;
    storage.write(CacheKey.decimals, d);
  }
}
