import 'package:get/get.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/currency_meta.dart';
import '../models/currency.dart';
import '../models/exchange_rate_table.dart';
import '../repositories/rate_repository.dart';
import 'auto_refresh_mixin.dart';

class RateRow {
  final Currency currency;
  final double rate;
  RateRow(this.currency, this.rate);
}

class RatesController extends GetxController with AutoRefreshMixin {
  final RateRepository repo;
  RatesController({required this.repo});

  final quote = kDefaultBase.obs; // CNY
  final search = ''.obs;
  final table = Rxn<ExchangeRateTable>();
  final isLoading = false.obs;
  final error = RxnString();

  /// All convertible rows against the current [quote], ordered common-first.
  /// Cached and only rebuilt when the table or quote actually changes, so a
  /// keystroke in the search box filters this list instead of re-sorting the
  /// full ~160-currency set every rebuild.
  List<RateRow> _allRows = const [];
  ExchangeRateTable? _rowsTable;
  String? _rowsQuote;

  List<RateRow> _buildAllRows(ExchangeRateTable t, String quoteCode) {
    final result = <RateRow>[];
    for (final code in sortByPopularity(t.usdRates.keys)) {
      if (code == quoteCode) continue;
      final r = t.rate(code, quoteCode);
      if (r == null) continue;
      result.add(RateRow(currencyOf(code), r));
    }
    return result;
  }

  List<RateRow> get rows {
    final t = table.value;
    if (t == null) return const [];
    // Rebuild the (expensive) sorted base list only when its inputs change.
    if (!identical(t, _rowsTable) || quote.value != _rowsQuote) {
      _allRows = _buildAllRows(t, quote.value);
      _rowsTable = t;
      _rowsQuote = quote.value;
    }
    final q = search.value.trim().toUpperCase();
    if (q.isEmpty) return _allRows;
    return _allRows.where((row) {
      final cur = row.currency;
      return cur.code.contains(q) ||
          cur.cnName.toUpperCase().contains(q) ||
          cur.enName.toUpperCase().contains(q) ||
          cur.jaName.toUpperCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
    initAutoRefresh();
  }

  /// Auto-refresh callback: force a fresh fetch on each interval tick.
  @override
  Future<void> refreshRates() => load(forceRefresh: true);

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    try {
      table.value = await repo.getRates(
        forceRefresh: forceRefresh,
        maxAge: refreshMaxAge,
      );
      error.value = null;
    } on ApiException catch (e) {
      // Keep showing the last data, but surface the failure so the rates page
      // isn't silently stale (previously this was swallowed entirely).
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
