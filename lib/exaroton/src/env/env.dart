import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Env {
  static final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  static String baseUrl = "https://api.exaroton.com/v1";

  static Future<String?> apiKey() async {
    return await _storage.read(key: "token");
  }
}