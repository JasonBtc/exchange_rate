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
              sendTimeout: ApiConst.timeout,
            ));

  Future<Map<String, dynamic>> getLatest(String base) async {
    // Retry transient failures (timeouts / connection errors) a few times with
    // a short backoff before surfacing a domain error. A non-transient response
    // (e.g. a 4xx or a payload whose `result` isn't success) fails fast.
    DioException? lastError;
    for (var attempt = 0; attempt <= ApiConst.maxRetries; attempt++) {
      try {
        final resp = await _dio.get('${ApiConst.base}/$base');
        final data = resp.data;
        if (data is Map<String, dynamic> && data['result'] == 'success') {
          return data;
        }
        throw ApiException('接口返回异常: ${data is Map ? data['result'] : data}');
      } on DioException catch (e) {
        lastError = e;
        if (!_isTransient(e) || attempt == ApiConst.maxRetries) {
          throw ApiException('网络请求失败: ${e.message}');
        }
        await Future<void>.delayed(ApiConst.retryBackoff * (attempt + 1));
      }
    }
    // Unreachable: the loop either returns or throws, but keeps the analyzer
    // happy about the non-null return type.
    throw ApiException('网络请求失败: ${lastError?.message}');
  }

  /// Timeouts and connection drops are worth retrying; an HTTP error response
  /// (bad status) or a cancellation is not.
  static bool _isTransient(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        return false;
    }
  }
}
