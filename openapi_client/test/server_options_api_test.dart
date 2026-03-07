import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ServerOptionsApi
void main() {
  final instance = Openapi().getServerOptionsApi();

  group(ServerOptionsApi, () {
    // Get server MOTD
    //
    //Future<GetServerMotd200Response> getServerMotd(String serverId) async
    test('test getServerMotd', () async {
      // TODO
    });

    // Get server ram
    //
    //Future<GetServerRam200Response> getServerRam(String serverId) async
    test('test getServerRam', () async {
      // TODO
    });

    // Change server MOTD
    //
    //Future<GetServerMotd200Response> postServerMotd(String serverId, PostServerMotdRequest postServerMotdRequest) async
    test('test postServerMotd', () async {
      // TODO
    });

    // Change server ram
    //
    //Future<GetServerRam200Response> postServerRam(String serverId, PostServerRamRequest postServerRamRequest) async
    test('test postServerRam', () async {
      // TODO
    });

  });
}
