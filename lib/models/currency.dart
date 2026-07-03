class Currency {
  final String code;
  final String cnName;
  final String symbol;
  final String flag; // emoji 国旗

  const Currency({
    required this.code,
    required this.cnName,
    required this.symbol,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
