// Credits to https://github.com/CidQu (https://github.com/CidQu/exaroton/blob/main/lib/src/main.dart)
import 'env/env.dart';
import 'package:http/http.dart' as http;

class Exaroton {
  late final String key;
  Exaroton({required this.key});

  Future<({String body, String statusCode})> get(String endpoint) async {
    var postUrl = '${Env.baseUrl}/${endpoint}';

    final response = await http.get(
      Uri.parse('${postUrl}'),
      headers: {
        'Authorization': 'Bearer ${key}',
        'Content-Type': 'application/json',
      },
    );
    return (body: response.body, statusCode: response.statusCode.toString());
  }

  Future<({String body, String statusCode})> post(
    String endpoint,
    String body,
  ) async {
    var postUrl = '${Env.baseUrl}/$endpoint';

    final response = await http.post(
      Uri.parse('$postUrl'),
      headers: {
        'Authorization': 'Bearer ${key}',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    return (body: response.body, statusCode: response.statusCode.toString());
  }
}
