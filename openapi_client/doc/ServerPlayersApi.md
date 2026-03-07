# openapi_client.api.ServerPlayersApi

## Load the API package
```dart
import 'package:openapi_client/api.dart';
```

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deletePlayerList**](ServerPlayersApi.md#deleteplayerlist) | **DELETE** /servers/{serverId}/playerlists/{list}/ | Remove entries from player list
[**getPlayerList**](ServerPlayersApi.md#getplayerlist) | **GET** /servers/{serverId}/playerlists/{list}/ | Get player list contents
[**getPlayerLists**](ServerPlayersApi.md#getplayerlists) | **GET** /servers/{serverId}/playerlists/ | Get available player lists
[**putPlayerList**](ServerPlayersApi.md#putplayerlist) | **PUT** /servers/{serverId}/playerlists/{list}/ | Add entries to player list


# **deletePlayerList**
> GetPlayerList200Response deletePlayerList(serverId, list, deletePlayerListRequestBody)

Remove entries from player list

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerPlayersApi();
final serverId = serverId_example; // String | Unique server ID
final list = list_example; // String | Player list name
final deletePlayerListRequestBody = DeletePlayerListRequestBody(); // DeletePlayerListRequestBody | 

try {
    final result = api_instance.deletePlayerList(serverId, list, deletePlayerListRequestBody);
    print(result);
} catch (e) {
    print('Exception when calling ServerPlayersApi->deletePlayerList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **list** | **String**| Player list name | 
 **deletePlayerListRequestBody** | [**DeletePlayerListRequestBody**](DeletePlayerListRequestBody.md)|  | [optional] 

### Return type

[**GetPlayerList200Response**](GetPlayerList200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlayerList**
> GetPlayerList200Response getPlayerList(serverId, list)

Get player list contents

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerPlayersApi();
final serverId = serverId_example; // String | Unique server ID
final list = list_example; // String | Player list name

try {
    final result = api_instance.getPlayerList(serverId, list);
    print(result);
} catch (e) {
    print('Exception when calling ServerPlayersApi->getPlayerList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **list** | **String**| Player list name | 

### Return type

[**GetPlayerList200Response**](GetPlayerList200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlayerLists**
> GetPlayerLists200Response getPlayerLists(serverId)

Get available player lists

A player list is a list of players such as the whitelist, ops or bans. Player list entries are usually usernames, but might be something else, e.g. IPs in the banned-ips list. All player list operations are storage operations that might take a while, so try to reduce the amount of requests and combine actions when possible (e.g. adding/deleting multiple entries at once). Player lists are also cached and might not immediately return new results when changed through other methods.

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerPlayersApi();
final serverId = serverId_example; // String | Unique server ID

try {
    final result = api_instance.getPlayerLists(serverId);
    print(result);
} catch (e) {
    print('Exception when calling ServerPlayersApi->getPlayerLists: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 

### Return type

[**GetPlayerLists200Response**](GetPlayerLists200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putPlayerList**
> GetPlayerList200Response putPlayerList(serverId, list, putPlayerListRequestBody)

Add entries to player list

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerPlayersApi();
final serverId = serverId_example; // String | Unique server ID
final list = list_example; // String | Player list name
final putPlayerListRequestBody = PutPlayerListRequestBody(); // PutPlayerListRequestBody | 

try {
    final result = api_instance.putPlayerList(serverId, list, putPlayerListRequestBody);
    print(result);
} catch (e) {
    print('Exception when calling ServerPlayersApi->putPlayerList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **list** | **String**| Player list name | 
 **putPlayerListRequestBody** | [**PutPlayerListRequestBody**](PutPlayerListRequestBody.md)|  | [optional] 

### Return type

[**GetPlayerList200Response**](GetPlayerList200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

