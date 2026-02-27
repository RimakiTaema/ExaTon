import 'dart:convert';
import '../http.dart';

class GetAccount {
  final String token;

  GetAccount({required this.token});

  Future<({String? token, int statusCode, String body})> fetch() async {
    final exaroton = Exaroton(key: token);
    var response = await exaroton.get("account");

    final data = jsonDecode(response.body);
    return (
      token: data['token'] as String?,
      statusCode: int.parse(response.statusCode),
      body: response.body,
    );
  }
}
