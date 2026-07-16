import 'package:get/get.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/exchange_rate_table.dart';
import '../repositories/rate_repository.dart';
import 'auto_refresh_mixin.dart';

class ConverterController extends GetxController with AutoRefreshMixin {
  final RateRepository repo;
  ConverterController({required this.repo});

  final base = kDefaultBase.obs;
  final target = kDefaultTarget.obs;
  final amount = 1.0.obs;
  final table = Rxn<ExchangeRateTable>();
  final isLoading = false.obs;
  final error = RxnString();

  double get result =>
      table.value?.convert(amount.value, base.value, target.value) ?? 0;

  double get unitRate =>
      table.value?.rate(base.value, target.value) ?? 0;

  /// Every currency code the live rate table can convert. Empty until the
  /// first successful load; the picker falls back to the full known set.
  List<String> get availableCodes =>
      table.value?.usdRates.keys.toList() ?? const [];

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
    error.value = null;
    try {
      table.value = await repo.getRates(
        forceRefresh: forceRefresh,
        maxAge: refreshMaxAge,
      );
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void setAmount(String raw) {
    final v = double.tryParse(raw.trim()) ?? 0;
    // Amounts are non-negative; reject a stray sign / scientific-notation
    // negative rather than converting a negative figure.
    amount.value = v < 0 ? 0 : v;
  }

  void setBase(String code) => base.value = code;
  void setTarget(String code) => target.value = code;

  void swap() {
    final b = base.value;
    base.value = target.value;
    target.value = b;
  }
}
