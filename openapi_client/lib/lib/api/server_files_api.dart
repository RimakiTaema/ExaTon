//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ServerFilesApi {
  ServerFilesApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Delete a file or directory
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  Future<Response> deleteFileWithHttpInfo(String serverId, String path,) async {
    // ignore: prefer_const_declarations
    final requestPath = r'/servers/{serverId}/files/data/{path}/'
      .replaceAll('{serverId}', serverId)
      .replaceAll('{path}', path);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      requestPath,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Delete a file or directory
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  Future<GetStartServer200Response?> deleteFile(String serverId, String path,) async {
    final response = await deleteFileWithHttpInfo(serverId, path,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStartServer200Response',) as GetStartServer200Response;
    
    }
    return null;
  }

  /// Get config file data
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  Future<Response> getConfigFileDataWithHttpInfo(String serverId, String path,) async {
    // ignore: prefer_const_declarations
    final requestPath = r'/servers/{serverId}/files/config/{path}/'
      .replaceAll('{serverId}', serverId)
      .replaceAll('{path}', path);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      requestPath,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get config file data
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  Future<GetConfigFileData200Response?> getConfigFileData(String serverId, String path,) async {
    final response = await getConfigFileDataWithHttpInfo(serverId, path,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetConfigFileData200Response',) as GetConfigFileData200Response;
    
    }
    return null;
  }

  /// Get file content
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  Future<Response> getFileContentWithHttpInfo(String serverId, String path,) async {
    // ignore: prefer_const_declarations
    final requestPath = r'/servers/{serverId}/files/data/{path}/'
      .replaceAll('{serverId}', serverId)
      .replaceAll('{path}', path);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      requestPath,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get file content
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  Future<MultipartFile?> getFileContent(String serverId, String path,) async {
    final response = await getFileContentWithHttpInfo(serverId, path,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MultipartFile',) as MultipartFile;
    
    }
    return null;
  }

  /// Get file info
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  Future<Response> getFileInfoWithHttpInfo(String serverId, String path,) async {
    // ignore: prefer_const_declarations
    final requestPath = r'/servers/{serverId}/files/info/{path}/'
      .replaceAll('{serverId}', serverId)
      .replaceAll('{path}', path);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      requestPath,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Get file info
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  Future<GetFileInfo200Response?> getFileInfo(String serverId, String path,) async {
    final response = await getFileInfoWithHttpInfo(serverId, path,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetFileInfo200Response',) as GetFileInfo200Response;
    
    }
    return null;
  }

  /// Update config file
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  ///
  /// * [Map<String, Object>] requestBody:
  Future<Response> postConfigFileDataWithHttpInfo(String serverId, String path, { Map<String, Object>? requestBody, }) async {
    // ignore: prefer_const_declarations
    final requestPath = r'/servers/{serverId}/files/config/{path}/'
      .replaceAll('{serverId}', serverId)
      .replaceAll('{path}', path);

    // ignore: prefer_final_locals
    Object? postBody = requestBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      requestPath,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Update config file
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  ///
  /// * [Map<String, Object>] requestBody:
  Future<GetConfigFileData200Response?> postConfigFileData(String serverId, String path, { Map<String, Object>? requestBody, }) async {
    final response = await postConfigFileDataWithHttpInfo(serverId, path,  requestBody: requestBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetConfigFileData200Response',) as GetConfigFileData200Response;
    
    }
    return null;
  }

  /// Write file content or create a directory
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  ///
  /// * [MultipartFile] body:
  Future<Response> putFileDataWithHttpInfo(String serverId, String path, { MultipartFile? body, }) async {
    // ignore: prefer_const_declarations
    final requestPath = r'/servers/{serverId}/files/data/{path}/'
      .replaceAll('{serverId}', serverId)
      .replaceAll('{path}', path);

    // ignore: prefer_final_locals
    Object? postBody = body;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/octet-stream', 'inode/directory'];


    return apiClient.invokeAPI(
      requestPath,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Write file content or create a directory
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] path (required):
  ///   File path
  ///
  /// * [MultipartFile] body:
  Future<GetStartServer200Response?> putFileData(String serverId, String path, { MultipartFile? body, }) async {
    final response = await putFileDataWithHttpInfo(serverId, path,  body: body, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetStartServer200Response',) as GetStartServer200Response;
    
    }
    return null;
  }
}
