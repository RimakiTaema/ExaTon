//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ServerPlayersApi {
  ServerPlayersApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Remove entries from player list
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] list (required):
  ///   Player list name
  ///
  /// * [DeletePlayerListRequestBody] deletePlayerListRequestBody:
  Future<Response> deletePlayerListWithHttpInfo(String serverId, String list, { DeletePlayerListRequestBody? deletePlayerListRequestBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/playerlists/{list}/'
      .replaceAll('{serverId}', serverId)
      .replaceAll('{list}', list);

    // ignore: prefer_final_locals
    Object? postBody = deletePlayerListRequestBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Remove entries from player list
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] list (required):
  ///   Player list name
  ///
  /// * [DeletePlayerListRequestBody] deletePlayerListRequestBody:
  Future<GetPlayerList200Response?> deletePlayerList(String serverId, String list, { DeletePlayerListRequestBody? deletePlayerListRequestBody, }) async {
    final response = await deletePlayerListWithHttpInfo(serverId, list,  deletePlayerListRequestBody: deletePlayerListRequestBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetPlayerList200Response',) as GetPlayerList200Response;
    
    }
    return null;
  }

  /// Get player list contents
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] list (required):
  ///   Player list name
  Future<Response> getPlayerListWithHttpInfo(String serverId, String list,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/playerlists/{list}/'
      .replaceAll('{serverId}', serverId)
      .replaceAll('{list}', list);

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

  /// Get player list contents
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] list (required):
  ///   Player list name
  Future<GetPlayerList200Response?> getPlayerList(String serverId, String list,) async {
    final response = await getPlayerListWithHttpInfo(serverId, list,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetPlayerList200Response',) as GetPlayerList200Response;
    
    }
    return null;
  }

  /// Get available player lists
  ///
  /// A player list is a list of players such as the whitelist, ops or bans. Player list entries are usually usernames, but might be something else, e.g. IPs in the banned-ips list. All player list operations are storage operations that might take a while, so try to reduce the amount of requests and combine actions when possible (e.g. adding/deleting multiple entries at once). Player lists are also cached and might not immediately return new results when changed through other methods.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<Response> getPlayerListsWithHttpInfo(String serverId,) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/playerlists/'
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

  /// Get available player lists
  ///
  /// A player list is a list of players such as the whitelist, ops or bans. Player list entries are usually usernames, but might be something else, e.g. IPs in the banned-ips list. All player list operations are storage operations that might take a while, so try to reduce the amount of requests and combine actions when possible (e.g. adding/deleting multiple entries at once). Player lists are also cached and might not immediately return new results when changed through other methods.
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  Future<GetPlayerLists200Response?> getPlayerLists(String serverId,) async {
    final response = await getPlayerListsWithHttpInfo(serverId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetPlayerLists200Response',) as GetPlayerLists200Response;
    
    }
    return null;
  }

  /// Add entries to player list
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] list (required):
  ///   Player list name
  ///
  /// * [PutPlayerListRequestBody] putPlayerListRequestBody:
  Future<Response> putPlayerListWithHttpInfo(String serverId, String list, { PutPlayerListRequestBody? putPlayerListRequestBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/servers/{serverId}/playerlists/{list}/'
      .replaceAll('{serverId}', serverId)
      .replaceAll('{list}', list);

    // ignore: prefer_final_locals
    Object? postBody = putPlayerListRequestBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Add entries to player list
  ///
  /// Parameters:
  ///
  /// * [String] serverId (required):
  ///   Unique server ID
  ///
  /// * [String] list (required):
  ///   Player list name
  ///
  /// * [PutPlayerListRequestBody] putPlayerListRequestBody:
  Future<GetPlayerList200Response?> putPlayerList(String serverId, String list, { PutPlayerListRequestBody? putPlayerListRequestBody, }) async {
    final response = await putPlayerListWithHttpInfo(serverId, list,  putPlayerListRequestBody: putPlayerListRequestBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetPlayerList200Response',) as GetPlayerList200Response;
    
    }
    return null;
  }
}
