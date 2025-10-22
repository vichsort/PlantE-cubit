import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      print("SecureStorageService: Token saved successfully.");
    } catch (e) {
      print("SecureStorageService: Error saving token - $e");
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        print("SecureStorageService: Token retrieved successfully.");
      } else {
        print("SecureStorageService: No token found.");
      }
      return token;
    } catch (e) {
      print("SecureStorageService: Error reading token - $e");
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      print("SecureStorageService: Token deleted successfully.");
    } catch (e) {
      print("SecureStorageService: Error deleting token - $e");
    }
  }
}