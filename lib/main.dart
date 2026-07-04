import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'core/app_translations.dart';
import 'core/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final box = GetStorage();
  final dark = box.read(CacheKey.themeMode) ?? false;
  final localeKey = box.read(CacheKey.localeKey);
  runApp(ExchangeRateApp(
    startDark: dark,
    startLocale: appLocaleOf(localeKey is String ? localeKey : kDefaultLocaleKey)
        .locale,
  ));
}

class ExchangeRateApp extends StatelessWidget {
  final bool startDark;
  final Locale startLocale;
  const ExchangeRateApp({
    super.key,
    required this.startDark,
    required this.startLocale,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'app_title'.tr,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: startLocale,
      fallbackLocale: appLocaleOf(kDefaultLocaleKey).locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: startDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: Routes.home,
      getPages: AppPages.pages,
    );
  }
}
