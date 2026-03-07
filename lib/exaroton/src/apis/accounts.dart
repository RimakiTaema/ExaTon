import 'package:openapi_client/api.dart';
import '../env/env.dart';
class GetAccount {
  final String token;

  GetAccount({required this.token});

  Future<GetAccount200Response> run() async {
    final apiClient = ApiClient(basePath: Env.baseUrl.toString());
    apiClient.addDefaultHeader('Authorization', 'Bearer $token');

    final accountApi = AccountApi(apiClient);
    final response = await accountApi.getAccount();
    if (response == null) {
      throw Exception('Failed to get account');
    }

    return response;
  }
}
