import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exchange_rate/main.dart';

void main() {
  test('ExchangeRateApp constructs with startDark flag', () {
    const zh = Locale('zh', 'CN');
    const light = ExchangeRateApp(startDark: false, startLocale: zh);
    const dark = ExchangeRateApp(startDark: true, startLocale: zh);
    expect(light.startDark, isFalse);
    expect(dark.startDark, isTrue);
  });
}
