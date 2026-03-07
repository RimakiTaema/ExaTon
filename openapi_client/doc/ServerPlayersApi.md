# openapi.api.ServerPlayersApi

## Load the API package
```dart
import 'package:openapi/api.dart';
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
import 'package:openapi/api.dart';

final api = Openapi().getServerPlayersApi();
final String serverId = serverId_example; // String | Unique server ID
final String list = list_example; // String | Player list name
final DeletePlayerListRequestBody deletePlayerListRequestBody = ; // DeletePlayerListRequestBody | 

try {
    final response = api.deletePlayerList(serverId, list, deletePlayerListRequestBody);
    print(response);
} on DioException catch (e) {
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
import 'package:openapi/api.dart';

final api = Openapi().getServerPlayersApi();
final String serverId = serverId_example; // String | Unique server ID
final String list = list_example; // String | Player list name

try {
    final response = api.getPlayerList(serverId, list);
    print(response);
} on DioException catch (e) {
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
import 'package:openapi/api.dart';

final api = Openapi().getServerPlayersApi();
final String serverId = serverId_example; // String | Unique server ID

try {
    final response = api.getPlayerLists(serverId);
    print(response);
} on DioException catch (e) {
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
import 'package:openapi/api.dart';

final api = Openapi().getServerPlayersApi();
final String serverId = serverId_example; // String | Unique server ID
final String list = list_example; // String | Player list name
final PutPlayerListRequestBody putPlayerListRequestBody = ; // PutPlayerListRequestBody | 

try {
    final response = api.putPlayerList(serverId, list, putPlayerListRequestBody);
    print(response);
} on DioException catch (e) {
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

