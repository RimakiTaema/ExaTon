import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ServersApi
void main() {
  final instance = Openapi().getServersApi();

  group(ServersApi, () {
    // Get a server
    //
    //Future<GetServer200Response> getServer(String serverId) async
    test('test getServer', () async {
      // TODO
    });

    // Get all servers
    //
    //Future<GetServers200Response> getServers() async
    test('test getServers', () async {
      // TODO
    });

  });
}
