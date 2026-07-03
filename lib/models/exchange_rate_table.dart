class ExchangeRateTable {
  final String base; // 通常 'USD'
  final Map<String, double> usdRates;
  final DateTime updatedAt;

  ExchangeRateTable({
    required this.base,
    required this.usdRates,
    required this.updatedAt,
  });

  factory ExchangeRateTable.fromApi(Map<String, dynamic> json) {
    final rawRates = (json['rates'] as Map).map(
      (k, v) => MapEntry(k as String, (v as num).toDouble()),
    );
    final unix = (json['time_last_update_unix'] as num?)?.toInt();
    return ExchangeRateTable(
      base: json['base_code'] as String? ?? 'USD',
      usdRates: rawRates,
      updatedAt: unix != null
          ? DateTime.fromMillisecondsSinceEpoch(unix * 1000)
          : DateTime.now(),
    );
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

  Map<String, dynamic> toJson() => {
        'base': base,
        'usdRates': usdRates,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory ExchangeRateTable.fromJson(Map<String, dynamic> json) {
    final rates = (json['usdRates'] as Map).map(
      (k, v) => MapEntry(k as String, (v as num).toDouble()),
    );
    return ExchangeRateTable(
      base: json['base'] as String,
      usdRates: rates,
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }
}
