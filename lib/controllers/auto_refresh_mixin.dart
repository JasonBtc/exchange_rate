import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import 'settings_controller.dart';

/// True when running under `flutter test`. The test runner sets the
/// `FLUTTER_TEST` environment variable; unlike `Get.testMode` this can't be
/// silently reset by `Get.reset()` between tests, so the auto-refresh timer
/// stays disabled for the whole suite (a live periodic timer would trip the
/// framework's `!timersPending` assertion at tree teardown).
final bool _isFlutterTest =
    !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

/// Drives interval-based auto refresh from the user's 刷新频率 setting.
///
/// Mixed into the rate-bearing controllers so a change to
/// [SettingsController.refreshMinutes] (手动 / 15 分钟 / 1 小时) starts, restarts,
/// or stops a periodic [load]. When the setting is `0` (手动) no timer runs.
///
/// The [SettingsController] lookup is guarded by [Get.isRegistered] so tests
/// that register a controller without settings (e.g. the rates-page widget
/// test) don't fail — they simply run without auto refresh. The worker and
/// timer are torn down in [onClose] so nothing leaks.
mixin AutoRefreshMixin on GetxController {
  Worker? _refreshBinder;
  Timer? _refreshTimer;

  /// Triggers a refresh of this controller's rate data. Implemented by the
  /// host controller (forceRefresh so the interval actually re-fetches).
  Future<void> refreshRates();

  /// Cache-freshness window derived from the user's 刷新频率 setting: a table
  /// older than the chosen interval is considered stale on the next [load].
  /// Returns null (手动, or no settings registered) so the repository falls
  /// back to [ApiConst.defaultMaxAge].
  Duration? get refreshMaxAge {
    if (!Get.isRegistered<SettingsController>()) return null;
    final minutes = Get.find<SettingsController>().refreshMinutes.value;
    return minutes <= 0 ? null : Duration(minutes: minutes);
  }

  /// Call from the host controller's `onInit` (after `super.onInit()`).
  void initAutoRefresh() {
    // Skip the real periodic timer under widget tests: a pending periodic
    // timer would trip the framework's `!timersPending` assertion when the
    // tree is torn down. We can't rely on Get.testMode here — Get.reset() in a
    // test's tearDown rebuilds the root controller and clears it, so it's false
    // for every test after the first.
    if (_isFlutterTest) return;
    if (!Get.isRegistered<SettingsController>()) return;
    final settings = Get.find<SettingsController>();
    _applyInterval(settings.refreshMinutes.value);
    _refreshBinder = ever<int>(settings.refreshMinutes, _applyInterval);
  }

  void _applyInterval(int minutes) {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    if (minutes <= 0) return; // 手动: no auto refresh
    _refreshTimer = Timer.periodic(
      Duration(minutes: minutes),
      (_) => refreshRates(),
    );
  }

  @override
  void onClose() {
    _refreshBinder?.dispose();
    _refreshTimer?.cancel();
    super.onClose();
  }
}
