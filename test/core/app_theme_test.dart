import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exchange_rate/core/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('exposes accent brand color aligned with design token', () {
      expect(AppTheme.accent, const Color(0xFF2F6BFF));
    });

    test('light theme uses Material 3 and light brightness', () {
      final theme = AppTheme.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('dark theme uses Material 3 and dark brightness', () {
      final theme = AppTheme.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('both themes seed from the accent color', () {
      expect(AppTheme.light.colorScheme.primary, isNotNull);
      expect(AppTheme.dark.colorScheme.primary, isNotNull);
    });

    test('card theme has 20 radius rounded rectangle shape', () {
      final lightShape = AppTheme.light.cardTheme.shape;
      final darkShape = AppTheme.dark.cardTheme.shape;
      expect(lightShape, isA<RoundedRectangleBorder>());
      expect(darkShape, isA<RoundedRectangleBorder>());
      final lightRadius =
          ((lightShape as RoundedRectangleBorder).borderRadius as BorderRadius)
              .topLeft;
      expect(lightRadius, const Radius.circular(20));
    });
  });
}
