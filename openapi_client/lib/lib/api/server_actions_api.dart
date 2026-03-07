//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ServerActionsApi {
  ServerActionsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Extend server stop timer
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [ExtendServerStopTimeRequestBody] extendServerStopTimeRequestBody:
  Future<Response> extendServerStopTimeWithHttpInfo(String serverId, { ExtendServerStopTimeRequestBody? extendServerStopTimeRequestBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/extend-time/'
      .replaceAll('{serverId}', serverId);

    // ignore: prefer_final_locals
    Object? postBody = extendServerStopTimeRequestBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Extend server stop timer
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [ExtendServerStopTimeRequestBody] extendServerStopTimeRequestBody:
  Future<GetStartServer200Response?> extendServerStopTime(String serverId, { ExtendServerStopTimeRequestBody? extendServerStopTimeRequestBody, }) async {
    final response = await extendServerStopTimeWithHttpInfo(serverId,  extendServerStopTimeRequestBody: extendServerStopTimeRequestBody, );
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

  /// Start a server
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<Response> getStartServerWithHttpInfo(String serverId,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/start/'
      .replaceAll('{serverId}', serverId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Start a server
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<GetStartServer200Response?> getStartServer(String serverId,) async {
    final response = await getStartServerWithHttpInfo(serverId,);
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

  /// Execute a server command
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [PostServerCommandRequestBody] postServerCommandRequestBody:
  Future<Response> postServerCommandWithHttpInfo(String serverId, { PostServerCommandRequestBody? postServerCommandRequestBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/command/'
      .replaceAll('{serverId}', serverId);

    // ignore: prefer_final_locals
    Object? postBody = postServerCommandRequestBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Execute a server command
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [PostServerCommandRequestBody] postServerCommandRequestBody:
  Future<GetStartServer200Response?> postServerCommand(String serverId, { PostServerCommandRequestBody? postServerCommandRequestBody, }) async {
    final response = await postServerCommandWithHttpInfo(serverId,  postServerCommandRequestBody: postServerCommandRequestBody, );
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

  /// Start a server with own credits
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [PostStartServerRequest] postStartServerRequest:
  Future<Response> postStartServerWithHttpInfo(String serverId, { PostStartServerRequest? postStartServerRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/start/'
      .replaceAll('{serverId}', serverId);

    // ignore: prefer_final_locals
    Object? postBody = postStartServerRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Start a server with own credits
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [PostStartServerRequest] postStartServerRequest:
  Future<GetStartServer200Response?> postStartServer(String serverId, { PostStartServerRequest? postStartServerRequest, }) async {
    final response = await postStartServerWithHttpInfo(serverId,  postStartServerRequest: postStartServerRequest, );
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

  /// Restart a server
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<Response> restartServerWithHttpInfo(String serverId,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/restart/'
      .replaceAll('{serverId}', serverId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Restart a server
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<GetStartServer200Response?> restartServer(String serverId,) async {
    final response = await restartServerWithHttpInfo(serverId,);
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

  /// Stop a server
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<Response> stopServerWithHttpInfo(String serverId,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/stop/'
      .replaceAll('{serverId}', serverId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Stop a server
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<GetStartServer200Response?> stopServer(String serverId,) async {
    final response = await stopServerWithHttpInfo(serverId,);
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
