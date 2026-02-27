import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  // Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: "api_token", value: token);
  }

  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: "api_token");
  }

  // Save username
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: "username", value: username);
  }

  // Get username
  static Future<String?> getUsername() async {
    return await _storage.read(key: "username");
  }

  // Clear all (logout)
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}