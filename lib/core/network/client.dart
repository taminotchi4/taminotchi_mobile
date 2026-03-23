import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import '../utils/result.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final AuthInterceptor interceptor;

  ApiClient({required this.interceptor}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://89.223.126.116:3003/api/v1/",
        validateStatus: (status) => true,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    )
      ..interceptors.add(interceptor)
      ..interceptors.add(
        TalkerDioLogger(
          settings: const TalkerDioLoggerSettings(
            enabled: true,
            printRequestHeaders: true,
            printRequestData: true,
            printResponseHeaders: true,
            printResponseData: true,
            printResponseMessage: true,
          ),
        ),
      );
  }

  late final Dio _dio;

  /// Backend javobidan faqat statusCode va message ni oladi.
  Exception _parseError(Response response) {
    try {
      final data = response.data;
      if (data is Map) {
        final statusCode = data['statusCode'] ?? response.statusCode;
        final message = data['message'] ?? 'Noma\'lum xatolik';
        return Exception('$statusCode: $message');
      }
    } catch (_) {}
    return Exception('${response.statusCode}: Noma\'lum xatolik');
  }

  /// 401 kelsa interceptordagi logout'ni ishga tushiradi.
  bool _handleUnauthorized(Response response) {
    if (response.statusCode == 401) {
      interceptor.handleUnauthorized();
      return true;
    }
    return false;
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      if (_handleUnauthorized(response)) {
        return Result.error(Exception('401: Avtorizatsiya talab etiladi'));
      }
      if (response.statusCode != 200) {
        return Result.error(_parseError(response));
      }
      
      final responseData = response.data;
      if (responseData is! T) {
        return Result.error(Exception('Serverdan noto\'g\'ri turdagi ma\'lumot keldi. Kutilgan: $T, Kelgan: ${responseData.runtimeType}'));
      }
      
      return Result.ok(responseData);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    required Object data,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(path, data: data, options: options);
      if (_handleUnauthorized(response)) {
        return Result.error(Exception('401: Avtorizatsiya talab etiladi'));
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is! T) {
           return Result.error(Exception('Serverdan noto\'g\'ri turdagi ma\'lumot keldi. Kutilgan: $T, Kelgan: ${responseData.runtimeType}'));
        }
        return Result.ok(responseData);
      }
      return Result.error(_parseError(response));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<T>> patch<T>(
    String path, {
    required Object data,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(path, data:  data, options: options);
      if (_handleUnauthorized(response)) {
        return Result.error(Exception('401: Avtorizatsiya talab etiladi'));
      }
      if (response.statusCode != 200) {
        return Result.error(_parseError(response));
      }
      final responseData = response.data;
      if (responseData is! T) {
         return Result.error(Exception('Serverdan noto\'g\'ri turdagi ma\'lumot keldi. Kutilgan: $T, Kelgan: ${responseData.runtimeType}'));
      }
      return Result.ok(responseData);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<T>> delete<T>(String path) async {
    try {
      final response = await _dio.delete<T>(path);
      if (_handleUnauthorized(response)) {
        return Result.error(Exception('401: Avtorizatsiya talab etiladi'));
      }
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is! T) {
           return Result.error(Exception('Serverdan noto\'g\'ri turdagi ma\'lumot keldi. Kutilgan: $T, Kelgan: ${responseData.runtimeType}'));
        }
        return Result.ok(responseData);
      }
      return Result.error(_parseError(response));
    } on DioException catch (e) {
      return Result.error(Exception(e.message ?? e.toString()));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
