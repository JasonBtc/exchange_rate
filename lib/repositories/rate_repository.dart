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

  /// Shared in-flight fetch so concurrent callers (the converter and rates
  /// controllers both call [getRates] from `onInit` on the same repo instance)
  /// coalesce into a single network request instead of hitting the API twice.
  Future<ExchangeRateTable>? _inflight;

  Future<ExchangeRateTable> fetchFresh() {
    return _inflight ??= _doFetch();
  }

  Future<ExchangeRateTable> _doFetch() async {
    try {
      final json = await api.getLatest('USD');
      final ExchangeRateTable table;
      try {
        table = ExchangeRateTable.fromApi(json);
      } on FormatException catch (e) {
        // A malformed payload must surface as a domain error so getRates can
        // fall back to cache, rather than escaping as an uncaught CastError.
        throw ApiException('汇率数据解析失败: ${e.message}');
      }
      await storage.write(CacheKey.rateTable, table.toJson());
      return table;
    } finally {
      _inflight = null;
    }
  }

  ExchangeRateTable? cached() {
    final json = storage.read(CacheKey.rateTable);
    if (json == null) return null;
    // Lenient parse: a corrupt or schema-incompatible cache entry degrades to
    // null (and a fresh fetch) rather than crashing a cold start.
    return ExchangeRateTable.tryFromJson(json);
  }

  /// Returns rates, preferring a cached table younger than [maxAge]. Falls back
  /// to the cache on any network/parse failure. [maxAge] lets callers tie
  /// freshness to the user's 刷新频率 setting; when null the cache is only
  /// reused within [ApiConst.defaultMaxAge].
  Future<ExchangeRateTable> getRates({
    bool forceRefresh = false,
    DateTime? now,
    Duration? maxAge,
  }) async {
    final current = now ?? DateTime.now();
    final threshold = maxAge ?? ApiConst.defaultMaxAge;
    final local = cached();
    if (!forceRefresh &&
        local != null &&
        local.ageAt(current) >= Duration.zero &&
        local.ageAt(current) < threshold) {
      return local;
    }
    try {
      return await fetchFresh();
    } on ApiException {
      if (local != null) return local; // 离线兜底
      rethrow;
    }
  }
}
