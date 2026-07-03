import 'package:flutter_test/flutter_test.dart';

import 'package:exchange_rate/main.dart';

void main() {
  test('ExchangeRateApp constructs with startDark flag', () {
    const light = ExchangeRateApp(startDark: false);
    const dark = ExchangeRateApp(startDark: true);
    expect(light.startDark, isFalse);
    expect(dark.startDark, isTrue);
  });
}
