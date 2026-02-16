import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  const AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'token');
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'token', value: token);
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'token');
  }
}
