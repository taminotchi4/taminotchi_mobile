import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import '../utils/result.dart';
import 'auth_interceptor.dart';

class ApiClient {
  final AuthInterceptor interceptor;


  ApiClient({required this.interceptor}) {
    _dio = Dio(
      BaseOptions(baseUrl: "http://89.223.126.116:3003/api/v1/", validateStatus: (status) => true),
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

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var response = await _dio.get(path, queryParameters: queryParams);
      if (response.statusCode != 200) {
        return Result.error(Exception(response.data));
      }
      return Result.ok(response.data as T);
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
      var response = await _dio.post(path, data: data, options: options);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Result.ok(response.data as T);
      }
      return Result.error(Exception(response.data));
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
      var response = await _dio.patch(path, data: data, options: options);
      if (response.statusCode != 200) {
        return Result.error(Exception('hatolik ${response.data}'));
      }
      return Result.ok(response.data as T);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<T>> delete<T>(String path) async {
    try {
      final response = await _dio.delete<T>(path);
      if (response.statusCode == 200) {
        return Result.ok(response.data as T);
      }

      return Result.error(Exception(response.data.toString()));
    } on DioException catch (e) {
      return Result.error(Exception(e.toString()));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
