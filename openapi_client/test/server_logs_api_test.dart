import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ServerLogsApi
void main() {
  final instance = Openapi().getServerLogsApi();

  group(ServerLogsApi, () {
    // Get a server log
    //
    //Future<GetServerLog200Response> getServerLog(String serverId) async
    test('test getServerLog', () async {
      // TODO
    });

    // Upload a server log to mclo.gs
    //
    //Future<ShareServerLog200Response> shareServerLog(String serverId) async
    test('test shareServerLog', () async {
      // TODO
    });

  });
}
