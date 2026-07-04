import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:exchange_rate/controllers/rates_controller.dart';
import 'package:exchange_rate/controllers/settings_controller.dart';
import 'package:exchange_rate/core/api_client.dart';
import 'package:exchange_rate/core/app_translations.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';
import 'package:exchange_rate/views/settings/settings_page.dart';
import 'package:exchange_rate/views/widgets/app_segmented.dart';

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

class _MemRateStorage implements RateStorage {
  final Map<String, Map<String, dynamic>> box = {};
  @override
  Map<String, dynamic>? read(String key) => box[key];
  @override
  Future<void> write(String key, Map<String, dynamic> value) async =>
      box[key] = value;
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

  late SettingsController controller;

  setUp(() {
    controller =
        Get.put(SettingsController(storage: _MemSettingsStorage()));
    final repo =
        RateRepository(api: _StubApi(), storage: _MemRateStorage());
    Get.put(RatesController(repo: repo));
  });

  tearDown(() {
    Get.reset();
  });

  Widget wrap(Widget child) => GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        fallbackLocale: const Locale('zh', 'CN'),
        home: child,
      );

  group('SettingsPage', () {
    testWidgets('renders app bar 设置 title and section labels',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));
      await tester.pumpAndSettle();

      expect(find.text('设置'), findsOneWidget);
      expect(find.text('深色主题'), findsOneWidget);
      expect(find.text('适合夜间查价'), findsOneWidget);
      expect(find.text('换算精度'), findsOneWidget);
      expect(find.text('语言'), findsOneWidget);
      expect(find.text('刷新频率'), findsOneWidget);

      // 数据来源 sits at the bottom of the ListView (below the test viewport
      // after the 语言 panel was added), so scroll it into view first.
      await tester.scrollUntilVisible(
        find.text('数据来源'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('数据来源'), findsOneWidget);
    });

    testWidgets('theme SwitchListTile reflects controller.isDark',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      var tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.value, isFalse);

      controller.isDark.value = true;
      await tester.pump();

      tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.value, isTrue);
    });

    testWidgets('tapping the theme switch toggles controller state',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      expect(controller.isDark.value, isFalse);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(controller.isDark.value, isTrue);
    });

    testWidgets('renders SegmentedButton with 2/4/6 options and reflects selection',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      expect(find.byType(SegmentedButton<int>), findsOneWidget);
      expect(find.text('2 位'), findsOneWidget);
      expect(find.text('4 位'), findsOneWidget);
      expect(find.text('6 位'), findsOneWidget);

      final seg = tester
          .widget<SegmentedButton<int>>(find.byType(SegmentedButton<int>));
      expect(seg.selected, {2});
    });

    testWidgets('tapping 4 位 updates decimals to 4', (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      await tester.tap(find.text('4 位'));
      await tester.pumpAndSettle();

      expect(controller.decimals.value, 4);
      final seg = tester
          .widget<SegmentedButton<int>>(find.byType(SegmentedButton<int>));
      expect(seg.selected, {4});
    });

    testWidgets('tapping 6 位 updates decimals to 6', (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      await tester.tap(find.text('6 位'));
      await tester.pumpAndSettle();

      expect(controller.decimals.value, 6);
    });

    testWidgets('renders 刷新频率 segmented with 手动/15 分钟/1 小时',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      expect(find.byType(AppSegmented<int>), findsOneWidget);
      expect(find.text('手动'), findsOneWidget);
      expect(find.text('15 分钟'), findsOneWidget);
      expect(find.text('1 小时'), findsOneWidget);
      expect(find.text('下一次自动刷新'), findsOneWidget);
      expect(controller.refreshMinutes.value, 15);
    });

    testWidgets('tapping 1 小时 updates refreshMinutes to 60',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      await tester.tap(find.text('1 小时'));
      await tester.pumpAndSettle();

      expect(controller.refreshMinutes.value, 60);
    });

    testWidgets('tapping 手动 disables auto refresh and shows 已关闭',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      await tester.tap(find.text('手动'));
      await tester.pumpAndSettle();

      expect(controller.refreshMinutes.value, 0);
      expect(find.text('已关闭'), findsOneWidget);
    });

    testWidgets('数据来源 shows 主汇率源 and 立即同步汇率 action',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));
      await tester.pumpAndSettle();

      // The 数据来源 panel sits at the bottom of the ListView; scroll it into
      // view so its (lazily built) cells and action button exist.
      await tester.scrollUntilVisible(
        find.text('立即同步汇率'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('主汇率源'), findsOneWidget);
      expect(find.text('open.er-api.com'), findsOneWidget);
      expect(find.text('离线数据'), findsOneWidget);
      expect(find.text('立即同步汇率'), findsOneWidget);
    });

    testWidgets('语言 switcher renders three options with default 中文',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));
      await tester.pumpAndSettle();

      expect(find.text('语言'), findsOneWidget);
      expect(find.text('中文'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('日本語'), findsOneWidget);
      expect(controller.localeKey.value, 'zh_CN');
    });

    testWidgets('renders section labels in English under the en_US locale',
        (tester) async {
      // Pump the page directly in English (rather than tapping, which drives
      // Get.updateLocale → forceAppUpdate; that reassemble path is flaky in
      // the widget-test harness). This proves the .tr catalog localizes the
      // UI; the switch's state/persistence is covered in the controller test.
      await tester.pumpWidget(GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('zh', 'CN'),
        home: const SettingsPage(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Refresh rate'), findsOneWidget);
      expect(find.text('Dark theme'), findsOneWidget);
    });
  });
}
