import 'package:get/get.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/currency_meta.dart';
import '../models/currency.dart';
import '../models/exchange_rate_table.dart';
import '../repositories/rate_repository.dart';

class RateRow {
  final Currency currency;
  final double rate;
  RateRow(this.currency, this.rate);
}

class RatesController extends GetxController {
  final RateRepository repo;
  RatesController({required this.repo});

  final quote = kDefaultBase.obs; // CNY
  final search = ''.obs;
  final table = Rxn<ExchangeRateTable>();
  final isLoading = false.obs;

  List<RateRow> get rows {
    final t = table.value;
    if (t == null) return [];
    final q = search.value.trim().toUpperCase();
    final result = <RateRow>[];
    for (final code in sortByPopularity(t.usdRates.keys)) {
      if (code == quote.value) continue;
      final r = t.rate(code, quote.value);
      if (r == null) continue;
      final cur = currencyOf(code);
      if (q.isNotEmpty &&
          !code.contains(q) &&
          !cur.cnName.toUpperCase().contains(q) &&
          !cur.enName.toUpperCase().contains(q) &&
          !cur.jaName.toUpperCase().contains(q)) {
        continue;
      }
      result.add(RateRow(cur, r));
    }
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    try {
      table.value = await repo.getRates(forceRefresh: forceRefresh);
    } on ApiException {
      // 静默：保留上次数据
    } finally {
      isLoading.value = false;
    }
  }
}
