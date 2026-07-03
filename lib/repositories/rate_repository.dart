import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/exchange_rate_table.dart';

abstract class RateStorage {
  Map<String, dynamic>? read(String key);
  Future<void> write(String key, Map<String, dynamic> value);
}

class RateRepository {
  final ApiClient api;
  final RateStorage storage;

  RateRepository({required this.api, required this.storage});

  Future<ExchangeRateTable> fetchFresh() async {
    final json = await api.getLatest('USD');
    final table = ExchangeRateTable.fromApi(json);
    await storage.write(CacheKey.rateTable, table.toJson());
    return table;
  }
}
