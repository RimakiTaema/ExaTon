//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class CreditPoolsApi {
  CreditPoolsApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get a credit pool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] poolId (required):
  ///   Unique credit pool ID
  Future<Response> getCreditPoolWithHttpInfo(String poolId,) async {
    // ignore: prefer_const_declarations
    final path = r'/billing/pools/{poolId}/'
      .replaceAll('{poolId}', poolId);

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

  /// Get a credit pool
  ///
  /// Parameters:
  ///
  /// * [String] poolId (required):
  ///   Unique credit pool ID
  Future<GetCreditPool200Response?> getCreditPool(String poolId,) async {
    final response = await getCreditPoolWithHttpInfo(poolId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetCreditPool200Response',) as GetCreditPool200Response;
    
    }
    return null;
  }

  /// Get all members in a credit pool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] poolId (required):
  ///   Unique credit pool ID
  Future<Response> getCreditPoolMembersWithHttpInfo(String poolId,) async {
    // ignore: prefer_const_declarations
    final path = r'/billing/pools/{poolId}/members/'
      .replaceAll('{poolId}', poolId);

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

  /// Get all members in a credit pool
  ///
  /// Parameters:
  ///
  /// * [String] poolId (required):
  ///   Unique credit pool ID
  Future<GetCreditPoolMembers200Response?> getCreditPoolMembers(String poolId,) async {
    final response = await getCreditPoolMembersWithHttpInfo(poolId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetCreditPoolMembers200Response',) as GetCreditPoolMembers200Response;
    
    }
    return null;
  }

  /// Get all servers in a credit pool
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] poolId (required):
  ///   Unique credit pool ID
  Future<Response> getCreditPoolServersWithHttpInfo(String poolId,) async {
    // ignore: prefer_const_declarations
    final path = r'/billing/pools/{poolId}/servers/'
      .replaceAll('{poolId}', poolId);

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

  /// Get all servers in a credit pool
  ///
  /// Parameters:
  ///
  /// * [String] poolId (required):
  ///   Unique credit pool ID
  Future<GetServers200Response?> getCreditPoolServers(String poolId,) async {
    final response = await getCreditPoolServersWithHttpInfo(poolId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetServers200Response',) as GetServers200Response;
    
    }
    return null;
  }

  /// List all credit pools
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getCreditPoolsWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/billing/pools/';

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

  /// List all credit pools
  Future<GetCreditPools200Response?> getCreditPools() async {
    final response = await getCreditPoolsWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetCreditPools200Response',) as GetCreditPools200Response;
    
    }
    return null;
  }
}
