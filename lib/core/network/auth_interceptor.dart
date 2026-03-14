import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:taminotchi_app/core/routing/router.dart';
import 'package:taminotchi_app/core/routing/routes.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor({required this.secureStorage});

  final dio = Dio(
    BaseOptions(
      baseUrl: "http://89.223.126.116:3003/api/v1/",
    ),
  );



  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    var token = await secureStorage.read(key: 'token');

    if (token != null) {
      // options.headers['Authorization'] = token;
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 401) {
      var username = await secureStorage.read(key: 'username');
      var password = await secureStorage.read(key: 'password');

      if (username == null || password == null) await logout();

      var result = await dio.post('/auth/login', data: {'username': username, 'password': password});
      String? token = result.data['token'];

      if (result.statusCode != 200 || token == null) await logout();

      await secureStorage.write(key: "token", value: token);
      final headers = response.requestOptions.headers;
      headers["Authorization"] = "$token";

      var retry = await dio.fetch(
        RequestOptions(
          baseUrl: response.requestOptions.baseUrl,
          path: response.requestOptions.path,
          method: response.requestOptions.method,
          data: response.requestOptions.data,
          headers: headers,
        ),
      );
      if (retry.statusCode != 200) await logout();
      super.onResponse(response, handler);
    } else {
      super.onResponse(response, handler);
    }

  }

  Future<void> logout() async {
    await secureStorage.delete(key: "token");
    await secureStorage.delete(key: "username");
    await secureStorage.delete(key: "password");
    router.go(Routes.home);
    return;
  }
}
