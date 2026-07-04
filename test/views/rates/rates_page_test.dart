import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:exchange_rate/controllers/rates_controller.dart';
import 'package:exchange_rate/core/api_client.dart';
import 'package:exchange_rate/core/app_translations.dart';
import 'package:exchange_rate/repositories/rate_repository.dart';
import 'package:exchange_rate/views/rates/rates_page.dart';

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

void main() {
  setUpAll(() {
    Get.testMode = true;
  });

  setUp(() {
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
        home: child,
      );

  group('RatesPage', () {
    testWidgets('renders app bar 行情 title and search field', (tester) async {
      await tester.pumpWidget(wrap(const RatesPage()));
      await tester.pumpAndSettle();

      expect(find.text('行情'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders rows for non-quote currencies after load',
        (tester) async {
      final c = Get.find<RatesController>();
      await c.load();

      await tester.pumpWidget(wrap(const RatesPage()));
      await tester.pumpAndSettle();

      // USD row shown with 1 USD ≈ 7.2600 CNY. Match the full "美元 USD"
      // row label so the search hint (搜索美元、JPY、欧元) is not counted.
      expect(find.textContaining('美元 USD'), findsOneWidget);
      expect(find.textContaining('1 USD ≈ 7.2600 CNY'), findsOneWidget);
      // CNY row (the quote) should be excluded
      expect(find.textContaining('1 CNY ≈'), findsNothing);
    });

    testWidgets('typing in search filters the rows', (tester) async {
      final c = Get.find<RatesController>();
      await c.load();

      await tester.pumpWidget(wrap(const RatesPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'USD');
      await tester.pumpAndSettle();

      expect(find.textContaining('1 USD ≈'), findsOneWidget);
      expect(find.textContaining('1 EUR ≈'), findsNothing);
      expect(find.textContaining('1 JPY ≈'), findsNothing);
    });

    testWidgets('shows empty state text when no rows match search',
        (tester) async {
      final c = Get.find<RatesController>();
      await c.load();

      await tester.pumpWidget(wrap(const RatesPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ZZZ_NO_MATCH');
      await tester.pumpAndSettle();

      expect(find.text('没有匹配的币种'), findsOneWidget);
    });

    testWidgets('includes RefreshIndicator wrapping the list', (tester) async {
      final c = Get.find<RatesController>();
      await c.load();

      await tester.pumpWidget(wrap(const RatesPage()));
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
