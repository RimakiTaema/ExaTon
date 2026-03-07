import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ServerActionsApi
void main() {
  final instance = Openapi().getServerActionsApi();

  group(ServerActionsApi, () {
    // Extend server stop timer
    //
    //Future<GetStartServer200Response> extendServerStopTime(String serverId, { ExtendServerStopTimeRequestBody extendServerStopTimeRequestBody }) async
    test('test extendServerStopTime', () async {
      // TODO
    });

    // Start a server
    //
    //Future<GetStartServer200Response> getStartServer(String serverId) async
    test('test getStartServer', () async {
      // TODO
    });

    // Execute a server command
    //
    //Future<GetStartServer200Response> postServerCommand(String serverId, { PostServerCommandRequestBody postServerCommandRequestBody }) async
    test('test postServerCommand', () async {
      // TODO
    });

    // Start a server with own credits
    //
    //Future<GetStartServer200Response> postStartServer(String serverId, { PostStartServerRequest postStartServerRequest }) async
    test('test postStartServer', () async {
      // TODO
    });

    // Restart a server
    //
    //Future<GetStartServer200Response> restartServer(String serverId) async
    test('test restartServer', () async {
      // TODO
    });

    // Stop a server
    //
    //Future<GetStartServer200Response> stopServer(String serverId) async
    test('test stopServer', () async {
      // TODO
    });

  });
}
