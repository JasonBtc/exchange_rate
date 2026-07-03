import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/api_client.dart';
import '../controllers/converter_controller.dart';
import '../controllers/rates_controller.dart';
import '../controllers/settings_controller.dart';
import '../repositories/rate_repository.dart';

class GetStorageAdapter implements RateStorage {
  final _box = GetStorage();
  @override
  Map<String, dynamic>? read(String key) {
    final v = _box.read(key);
    return v == null ? null : Map<String, dynamic>.from(v);
  }

  @override
  Future<void> write(String key, Map<String, dynamic> value) =>
      _box.write(key, value);
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    final repo = RateRepository(
      api: ApiClient(),
      storage: GetStorageAdapter(),
    );
    Get.put<RateRepository>(repo, permanent: true);
    Get.put(SettingsController(), permanent: true);
    Get.put(ConverterController(repo: repo));
    Get.put(RatesController(repo: repo));
  }
}
