import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:exchange_rate/controllers/converter_controller.dart';
import 'package:exchange_rate/controllers/rates_controller.dart';
import 'package:exchange_rate/controllers/settings_controller.dart';
import 'package:exchange_rate/core/api_client.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';
import 'package:exchange_rate/views/home/home_page.dart';

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

  setUp(() {
    final repo =
        RateRepository(api: _StubApi(), storage: _MemRateStorage());
    Get.put(SettingsController(storage: _MemSettingsStorage()));
    Get.put(ConverterController(repo: repo));
    Get.put(RatesController(repo: repo));
  });

  tearDown(() {
    Get.reset();
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  group('HomePage', () {
    testWidgets('renders three NavigationBar destinations with expected labels',
        (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('换算'), findsWidgets);
      expect(find.text('行情'), findsWidgets);
      expect(find.text('设置'), findsWidgets);
    });

    testWidgets('starts on the first tab (换算) via IndexedStack index 0',
        (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));

      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 0);

      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, 0);
    });

    testWidgets('tapping 行情 destination switches IndexedStack to index 1',
        (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));

      await tester.tap(find.text('行情'));
      await tester.pumpAndSettle();

      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 1);

      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, 1);
    });

    testWidgets('tapping 设置 destination switches IndexedStack to index 2',
        (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));

      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();

      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 2);

      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, 2);
    });
  });
}
