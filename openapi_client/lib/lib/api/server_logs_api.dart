//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ServerLogsApi {
  ServerLogsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get a server log
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<Response> getServerLogWithHttpInfo(String serverId,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/logs/'
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

  /// Get a server log
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<GetServerLog200Response?> getServerLog(String serverId,) async {
    final response = await getServerLogWithHttpInfo(serverId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetServerLog200Response',) as GetServerLog200Response;
    
    }
    return null;
  }

  /// Upload a server log to mclo.gs
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<Response> shareServerLogWithHttpInfo(String serverId,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/logs/share/'
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

  /// Upload a server log to mclo.gs
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<ShareServerLog200Response?> shareServerLog(String serverId,) async {
    final response = await shareServerLogWithHttpInfo(serverId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ShareServerLog200Response',) as ShareServerLog200Response;
    
    }
    return null;
  }
}
