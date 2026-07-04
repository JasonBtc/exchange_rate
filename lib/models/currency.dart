class Currency {
  final String code;
  final String cnName;

  /// English display name. Falls back to [code] when not provided.
  final String enName;

  /// Japanese display name. Falls back to [cnName] (the shared CJK name is
  /// usually acceptable) when not provided.
  final String jaName;

  final String symbol;

  const Currency({
    required this.code,
    required this.cnName,
    required this.symbol,
    this.enName = '',
    this.jaName = '',
  });

  /// The display name for a UI language [key] (`zh_CN` / `en_US` / `ja_JP`),
  /// falling back gracefully: English → [code] when missing; Japanese →
  /// [cnName] (shared CJK) → [code] when missing; anything else → [cnName].
  String nameFor(String key) {
    switch (key) {
      case 'en_US':
        return enName.isNotEmpty ? enName : code;
      case 'ja_JP':
        if (jaName.isNotEmpty) return jaName;
        return cnName.isNotEmpty ? cnName : code;
      default:
        return cnName.isNotEmpty ? cnName : code;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
