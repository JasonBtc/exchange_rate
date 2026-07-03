import 'package:get/get.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/exchange_rate_table.dart';
import '../repositories/rate_repository.dart';

class ConverterController extends GetxController {
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

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    isLoading.value = true;
    error.value = null;
    try {
      table.value = await repo.getRates(forceRefresh: forceRefresh);
    } on ApiException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  void setAmount(String raw) {
    amount.value = double.tryParse(raw.trim()) ?? 0;
  }

  void setBase(String code) => base.value = code;
  void setTarget(String code) => target.value = code;

  void swap() {
    final b = base.value;
    base.value = target.value;
    target.value = b;
  }
}
