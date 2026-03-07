import 'package:dio/dio.dart';
import 'package:openapi/openapi.dart';

class GetAccount {
  final String token;

  GetAccount({required this.token});

  Future<Response<GetAccount200Response>> run() async {
    final dio = Dio();

    dio.options.headers["Authorization"] = "Bearer $token";

    final apiClient = AccountApi(dio, standardSerializers);

    final res = await apiClient.getAccount();

    return res;
  }
}
