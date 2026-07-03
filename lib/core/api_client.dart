import 'package:dio/dio.dart';
import 'constants.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: ApiConst.timeout,
              receiveTimeout: ApiConst.timeout,
            ));

  Future<Map<String, dynamic>> getLatest(String base) async {
    try {
      final resp = await _dio.get('${ApiConst.base}/$base');
      final data = resp.data;
      if (data is Map<String, dynamic> && data['result'] == 'success') {
        return data;
      }
      throw ApiException('接口返回异常: ${data is Map ? data['result'] : data}');
    } on DioException catch (e) {
      throw ApiException('网络请求失败: ${e.message}');
    }
  }
}
