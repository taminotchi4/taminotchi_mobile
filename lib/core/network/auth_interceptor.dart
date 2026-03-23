import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:taminotchi_app/core/routing/router.dart';
import 'package:taminotchi_app/core/routing/routes.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor({required this.secureStorage});

  final _refreshDio = Dio(
    BaseOptions(
      baseUrl: "http://89.223.126.116:3003/api/v1/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Re-login in progress flag to avoid multiple simultaneous attempts
  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.read(key: 'token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // NOTE: Since ApiClient uses validateStatus: (s) => true,
    // 401 comes here, not onError. ApiClient calls handleUnauthorized() directly.
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // This handles 401 for cases where validateStatus is NOT set to true
    if (err.response?.statusCode == 401) {
      await handleUnauthorized();
    }
    super.onError(err, handler);
  }

  /// Called by ApiClient when a 401 response is detected.
  /// Attempts to re-login using stored credentials.
  /// If re-login fails or no credentials are stored, performs logout.
  Future<void> handleUnauthorized() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final username = await secureStorage.read(key: 'username');
      final password = await secureStorage.read(key: 'password');

      if (username != null && password != null) {
        try {
          final result = await _refreshDio.post('client/login', data: {
            'phoneNumber': username,
            'password': password,
          });

          final data = result.data['data'];
          final String? newToken = data?['accessToken'];

          if (newToken != null) {
            await secureStorage.write(key: 'token', value: newToken);
            _isRefreshing = false;
            return; // Token yangilandi, keyingi so'rovlar yangi token bilan ketadi
          } else {
            await _logout();
          }
        } catch (e) {
          print('❌ Re-login failed: $e');
          await _logout();
        }
      } else {
        // Credentials mavjud emas — to'g'ridan-to'g'ri logout
        await _logout();
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _logout() async {
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'username');
    await secureStorage.delete(key: 'password');
    router.go(Routes.auth);
  }
}
