### Task 2: 币种模型与元数据

**Files:**
- Create: `exchange_rate/lib/models/currency.dart`
- Create: `exchange_rate/lib/core/currency_meta.dart`
- Create: `exchange_rate/lib/core/constants.dart`

**Interfaces:**
- Produces:
  - `class Currency { final String code; final String cnName; final String symbol; final String flag; }`（`==`/`hashCode` 按 `code`）
  - `const Map<String, Currency> kCurrencyMeta`（key 为币种代码）
  - `Currency currencyOf(String code)`（未知代码返回以 code 兜底的 Currency）
  - `class ApiConst { static const base = 'https://open.er-api.com/v6/latest'; }`
  - `class CacheKey { static const rateTable = 'rate_table'; }`
  - `const List<String> kDefaultCurrencies = ['CNY','USD','EUR','JPY','GBP','AUD','KRW','HKD','CAD','SGD'];`
  - `const String kDefaultBase = 'CNY';` `const String kDefaultTarget = 'USD';`

- [ ] **Step 1: 创建 constants.dart**

```dart
class ApiConst {
  static const String base = 'https://open.er-api.com/v6/latest';
  static const Duration timeout = Duration(seconds: 15);
}

class CacheKey {
  static const String rateTable = 'rate_table';
  static const String themeMode = 'theme_mode';
  static const String decimals = 'decimals';
}

const String kDefaultBase = 'CNY';
const String kDefaultTarget = 'USD';
const List<String> kDefaultCurrencies = [
  'CNY', 'USD', 'EUR', 'JPY', 'GBP', 'AUD', 'KRW', 'HKD', 'CAD', 'SGD',
];
```

- [ ] **Step 2: 创建 currency.dart**

```dart
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
```

- [ ] **Step 3: 创建 currency_meta.dart**

```dart
import '../models/currency.dart';

const Map<String, Currency> kCurrencyMeta = {
  'CNY': Currency(code: 'CNY', cnName: '人民币', symbol: '¥', flag: '🇨🇳'),
  'USD': Currency(code: 'USD', cnName: '美元', symbol: '\$', flag: '🇺🇸'),
  'EUR': Currency(code: 'EUR', cnName: '欧元', symbol: '€', flag: '🇪🇺'),
  'JPY': Currency(code: 'JPY', cnName: '日元', symbol: '¥', flag: '🇯🇵'),
  'GBP': Currency(code: 'GBP', cnName: '英镑', symbol: '£', flag: '🇬🇧'),
  'AUD': Currency(code: 'AUD', cnName: '澳元', symbol: '\$', flag: '🇦🇺'),
  'KRW': Currency(code: 'KRW', cnName: '韩元', symbol: '₩', flag: '🇰🇷'),
  'HKD': Currency(code: 'HKD', cnName: '港币', symbol: '\$', flag: '🇭🇰'),
  'CAD': Currency(code: 'CAD', cnName: '加元', symbol: '\$', flag: '🇨🇦'),
  'SGD': Currency(code: 'SGD', cnName: '新加坡元', symbol: '\$', flag: '🇸🇬'),
};

Currency currencyOf(String code) =>
    kCurrencyMeta[code] ??
    Currency(code: code, cnName: code, symbol: code, flag: '🏳️');
```

- [ ] **Step 4: 验证编译**

Run: `cd exchange_rate && flutter analyze lib/models lib/core`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
cd exchange_rate && git add lib/models/currency.dart lib/core/currency_meta.dart lib/core/constants.dart && git commit -m "feat: add currency model and metadata"
```

---

