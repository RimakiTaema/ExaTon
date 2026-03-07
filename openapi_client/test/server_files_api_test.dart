import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for ServerFilesApi
void main() {
  final instance = Openapi().getServerFilesApi();

  group(ServerFilesApi, () {
    // Delete a file or directory
    //
    //Future<GetStartServer200Response> deleteFile(String serverId, String path) async
    test('test deleteFile', () async {
      // TODO
    });

    // Get config file data
    //
    //Future<GetConfigFileData200Response> getConfigFileData(String serverId, String path) async
    test('test getConfigFileData', () async {
      // TODO
    });

    // Get file content
    //
    //Future<Uint8List> getFileContent(String serverId, String path) async
    test('test getFileContent', () async {
      // TODO
    });

    // Get file info
    //
    //Future<GetFileInfo200Response> getFileInfo(String serverId, String path) async
    test('test getFileInfo', () async {
      // TODO
    });

    // Update config file
    //
    //Future<GetConfigFileData200Response> postConfigFileData(String serverId, String path, { BuiltMap<String, JsonObject> requestBody }) async
    test('test postConfigFileData', () async {
      // TODO
    });

    // Write file content or create a directory
    //
    //Future<GetStartServer200Response> putFileData(String serverId, String path, { MultipartFile body }) async
    test('test putFileData', () async {
      // TODO
    });

  });
}
