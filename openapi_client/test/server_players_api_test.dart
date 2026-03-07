import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ServerPlayersApi
void main() {
  final instance = Openapi().getServerPlayersApi();

  group(ServerPlayersApi, () {
    // Remove entries from player list
    //
    //Future<GetPlayerList200Response> deletePlayerList(String serverId, String list, { DeletePlayerListRequestBody deletePlayerListRequestBody }) async
    test('test deletePlayerList', () async {
      // TODO
    });

    // Get player list contents
    //
    //Future<GetPlayerList200Response> getPlayerList(String serverId, String list) async
    test('test getPlayerList', () async {
      // TODO
    });

    // Get available player lists
    //
    // A player list is a list of players such as the whitelist, ops or bans. Player list entries are usually usernames, but might be something else, e.g. IPs in the banned-ips list. All player list operations are storage operations that might take a while, so try to reduce the amount of requests and combine actions when possible (e.g. adding/deleting multiple entries at once). Player lists are also cached and might not immediately return new results when changed through other methods.
    //
    //Future<GetPlayerLists200Response> getPlayerLists(String serverId) async
    test('test getPlayerLists', () async {
      // TODO
    });

    // Add entries to player list
    //
    //Future<GetPlayerList200Response> putPlayerList(String serverId, String list, { PutPlayerListRequestBody putPlayerListRequestBody }) async
    test('test putPlayerList', () async {
      // TODO
    });

  });
}
