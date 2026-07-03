import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:exchange_rate/controllers/settings_controller.dart';
import 'package:exchange_rate/views/settings/settings_page.dart';

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
  });

  tearDown(() {
    Get.reset();
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  group('SettingsPage', () {
    testWidgets('renders app bar 设置 title and section labels',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      expect(find.text('设置'), findsOneWidget);
      expect(find.text('深色主题'), findsOneWidget);
      expect(find.text('适合夜间查价'), findsOneWidget);
      expect(find.text('换算精度'), findsOneWidget);
      expect(find.text('数据来源'), findsOneWidget);
      expect(find.text('open.er-api.com · 每日更新'), findsOneWidget);
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

    testWidgets('renders AboutListTile', (tester) async {
      await tester.pumpWidget(wrap(const SettingsPage()));

      expect(find.byType(AboutListTile), findsOneWidget);
    });
  });
}
