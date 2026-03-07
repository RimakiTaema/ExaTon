import 'package:openapi_client/api.dart';

class GetAccount {
  final String token;

  GetAccount({required this.token});

  Future<GetAccount200Response> run() async {
    final apiClient = ApiClient(basePath: 'https://api.exaroton.com/v1');
    apiClient.addDefaultHeader('Authorization', 'Bearer $token');

    final accountApi = AccountApi(apiClient);
    final res = await accountApi.getAccount();

    return res;
  }
}
