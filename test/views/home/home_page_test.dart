import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exchange_rate/views/home/home_page.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  group('HomePage', () {
    testWidgets('renders three NavigationBar destinations with expected labels',
        (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('换算'), findsWidgets);
      expect(find.text('行情'), findsWidgets);
      expect(find.text('设置'), findsWidgets);
    });

    testWidgets('starts on the first tab (换算) via IndexedStack index 0',
        (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));

      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 0);

      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, 0);
    });

    testWidgets('tapping 行情 destination switches IndexedStack to index 1',
        (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));

      await tester.tap(find.text('行情'));
      await tester.pumpAndSettle();

      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 1);

      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, 1);
    });

    testWidgets('tapping 设置 destination switches IndexedStack to index 2',
        (tester) async {
      await tester.pumpWidget(wrap(const HomePage()));

      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();

      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 2);

      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.selectedIndex, 2);
    });
  });
}
