# openapi_client.api.ServersApi

## Load the API package
```dart
import 'package:openapi_client/api.dart';
```

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getServer**](ServersApi.md#getserver) | **GET** /servers/{serverId}/ | Get a server
[**getServers**](ServersApi.md#getservers) | **GET** /servers/ | Get all servers


# **getServer**
> GetServer200Response getServer(serverId)

Get a server

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServersApi();
final serverId = serverId_example; // String | Unique server ID

try {
    final result = api_instance.getServer(serverId);
    print(result);
} catch (e) {
    print('Exception when calling ServersApi->getServer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 

### Return type

[**GetServer200Response**](GetServer200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getServers**
> GetServers200Response getServers()

Get all servers

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServersApi();

try {
    final result = api_instance.getServers();
    print(result);
} catch (e) {
    print('Exception when calling ServersApi->getServers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetServers200Response**](GetServers200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

