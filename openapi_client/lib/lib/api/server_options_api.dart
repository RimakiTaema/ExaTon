//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ServerOptionsApi {
  ServerOptionsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get server MOTD
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<Response> getServerMotdWithHttpInfo(String serverId,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/options/motd/'
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

  /// Get server MOTD
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<GetServerMotd200Response?> getServerMotd(String serverId,) async {
    final response = await getServerMotdWithHttpInfo(serverId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetServerMotd200Response',) as GetServerMotd200Response;
    
    }
    return null;
  }

  /// Get server ram
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<Response> getServerRamWithHttpInfo(String serverId,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/options/ram/'
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

  /// Get server ram
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<GetServerRam200Response?> getServerRam(String serverId,) async {
    final response = await getServerRamWithHttpInfo(serverId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetServerRam200Response',) as GetServerRam200Response;
    
    }
    return null;
  }

  /// Change server MOTD
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [PostServerMotdRequest] postServerMotdRequest (required):
  Future<Response> postServerMotdWithHttpInfo(String serverId, PostServerMotdRequest postServerMotdRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/options/motd/'
      .replaceAll('{serverId}', serverId);

    // ignore: prefer_final_locals
    Object? postBody = postServerMotdRequest;

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

  /// Change server MOTD
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [PostServerMotdRequest] postServerMotdRequest (required):
  Future<GetServerMotd200Response?> postServerMotd(String serverId, PostServerMotdRequest postServerMotdRequest,) async {
    final response = await postServerMotdWithHttpInfo(serverId, postServerMotdRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetServerMotd200Response',) as GetServerMotd200Response;
    
    }
    return null;
  }

  /// Change server ram
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [PostServerRamRequest] postServerRamRequest (required):
  Future<Response> postServerRamWithHttpInfo(String serverId, PostServerRamRequest postServerRamRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/options/ram/'
      .replaceAll('{serverId}', serverId);

    // ignore: prefer_final_locals
    Object? postBody = postServerRamRequest;

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

  /// Change server ram
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [PostServerRamRequest] postServerRamRequest (required):
  Future<GetServerRam200Response?> postServerRam(String serverId, PostServerRamRequest postServerRamRequest,) async {
    final response = await postServerRamWithHttpInfo(serverId, postServerRamRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetServerRam200Response',) as GetServerRam200Response;
    
    }
    return null;
  }
}
