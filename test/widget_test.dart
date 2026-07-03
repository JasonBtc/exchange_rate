import 'package:flutter_test/flutter_test.dart';

import 'package:exchange_rate/main.dart';

void main() {
  testWidgets('PlaceholderApp renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const PlaceholderApp());

    expect(find.text('Exchange Rate'), findsOneWidget);
  });
}
