class ExchangeRateTable {
  final String base; // 通常 'USD'
  final Map<String, double> usdRates;
  final DateTime updatedAt;

  ExchangeRateTable({
    required this.base,
    required this.usdRates,
    required this.updatedAt,
  });

  /// Parses the open.er-api.com payload defensively. Throws [FormatException]
  /// (never a raw `CastError`) when `rates` is missing/mistyped or empty, so
  /// callers can translate it into a domain error and fall back gracefully.
  factory ExchangeRateTable.fromApi(Map<String, dynamic> json) {
    final rates = _parseRates(json['rates'], source: 'rates');
    final unix = (json['time_last_update_unix'] as num?)?.toInt();
    return ExchangeRateTable(
      base: json['base_code'] is String ? json['base_code'] as String : 'USD',
      usdRates: rates,
      updatedAt: unix != null
          ? DateTime.fromMillisecondsSinceEpoch(unix * 1000)
          : DateTime.now(),
    );
  }

  /// Reads a `{code: rate}` map, skipping any entry whose key isn't a String
  /// or whose value isn't numeric. Throws [FormatException] if the field is
  /// not a map or yields no usable rates.
  static Map<String, double> _parseRates(Object? raw, {required String source}) {
    if (raw is! Map) {
      throw FormatException('汇率数据字段 "$source" 缺失或类型错误');
    }
    final rates = <String, double>{};
    raw.forEach((k, v) {
      if (k is String && v is num) rates[k] = v.toDouble();
    });
    if (rates.isEmpty) {
      throw FormatException('汇率数据字段 "$source" 为空');
    }
    return rates;
  }

  double? rate(String from, String to) {
    final rf = usdRates[from];
    final rt = usdRates[to];
    if (rf == null || rt == null || rf == 0) return null;
    return rt / rf;
  }

  double? convert(double amount, String from, String to) {
    final r = rate(from, to);
    return r == null ? null : amount * r;
  }

  bool isFromToday(DateTime now) =>
      updatedAt.year == now.year &&
      updatedAt.month == now.month &&
      updatedAt.day == now.day;

  /// How old this table is relative to [now]. Used for interval-based freshness
  /// (see [RateRepository.getRates]) instead of the coarser calendar-day check.
  Duration ageAt(DateTime now) => now.difference(updatedAt);

  Map<String, dynamic> toJson() => {
        'base': base,
        'usdRates': usdRates,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  /// Strict parse of a persisted table. Throws [FormatException] on any
  /// missing/mistyped field. Prefer [tryFromJson] for cache reads where a
  /// corrupt entry should degrade to null rather than crash startup.
  factory ExchangeRateTable.fromJson(Map<String, dynamic> json) {
    final rates = _parseRates(json['usdRates'], source: 'usdRates');
    final base = json['base'] is String ? json['base'] as String : 'USD';
    final ms = json['updatedAt'];
    if (ms is! int) {
      throw FormatException('缓存字段 "updatedAt" 缺失或类型错误');
    }
    return ExchangeRateTable(
      base: base,
      usdRates: rates,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(ms),
    );
  }

  /// Lenient parse for cache reads: returns null instead of throwing when the
  /// stored payload is corrupt or from an incompatible older schema, so a bad
  /// cache entry can never crash a cold start.
  static ExchangeRateTable? tryFromJson(Map<String, dynamic> json) {
    try {
      return ExchangeRateTable.fromJson(json);
    } on FormatException {
      return null;
    }
  }
}
