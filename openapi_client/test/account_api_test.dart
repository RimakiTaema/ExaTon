import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for AccountApi
void main() {
  final instance = Openapi().getAccountApi();

  group(AccountApi, () {
    // Get account info
    //
    //Future<GetAccount200Response> getAccount() async
    test('test getAccount', () async {
      // TODO
    });

  });
}
