import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

// tests for Server
void main() {
  final instance = ServerBuilder();
  // TODO add properties to the builder and call build()

  group(Server, () {
    // Unique server ID
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Server name
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Full server address
    // String address
    test('to test the property `address`', () async {
      // TODO
    });

    // The MOTD of the server
    // String motd
    test('to test the property `motd`', () async {
      // TODO
    });

    // ServerStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // Host machine the server is running on. Only available if the server is online.
    // String host
    test('to test the property `host`', () async {
      // TODO
    });

    // Port the server is listening on. Only available if the server is online.
    // int port
    test('to test the property `port`', () async {
      // TODO
    });

    // ServerPlayers players
    test('to test the property `players`', () async {
      // TODO
    });

    // ServerSoftware software
    test('to test the property `software`', () async {
      // TODO
    });

    // Whether the server is accessed via the Share Access feature
    // bool shared
    test('to test the property `shared`', () async {
      // TODO
    });

  });
}
