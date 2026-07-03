import 'package:get/get.dart';
import '../bindings/app_binding.dart';
import '../views/home/home_page.dart';

class Routes {
  static const String home = '/home';
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: AppBinding(),
    ),
  ];
}
