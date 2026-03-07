import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for CreditPoolsApi
void main() {
  final instance = Openapi().getCreditPoolsApi();

  group(CreditPoolsApi, () {
    // Get a credit pool
    //
    //Future<GetCreditPool200Response> getCreditPool(String poolId) async
    test('test getCreditPool', () async {
      // TODO
    });

    // Get all members in a credit pool
    //
    //Future<GetCreditPoolMembers200Response> getCreditPoolMembers(String poolId) async
    test('test getCreditPoolMembers', () async {
      // TODO
    });

    // Get all servers in a credit pool
    //
    //Future<GetServers200Response> getCreditPoolServers(String poolId) async
    test('test getCreditPoolServers', () async {
      // TODO
    });

    // List all credit pools
    //
    //Future<GetCreditPools200Response> getCreditPools() async
    test('test getCreditPools', () async {
      // TODO
    });

  });
}
