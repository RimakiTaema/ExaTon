import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

// tests for ServerPlayers
void main() {
  final instance = ServerPlayersBuilder();
  // TODO add properties to the builder and call build()

  group(ServerPlayers, () {
    // Maximum player count (slots)
    // int max
    test('to test the property `max`', () async {
      // TODO
    });

    // Current player count
    // int count
    test('to test the property `count`', () async {
      // TODO
    });

    // Current player list (not always available)
    // BuiltList<String> list
    test('to test the property `list`', () async {
      // TODO
    });

  });
}
