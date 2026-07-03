import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'core/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final dark = GetStorage().read(CacheKey.themeMode) ?? false;
  runApp(ExchangeRateApp(startDark: dark));
}

class ExchangeRateApp extends StatelessWidget {
  final bool startDark;
  const ExchangeRateApp({super.key, required this.startDark});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '汇率换算',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: startDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: Routes.home,
      getPages: AppPages.pages,
    );
  }
}
