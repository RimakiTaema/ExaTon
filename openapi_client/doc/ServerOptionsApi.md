# openapi_client.api.ServerOptionsApi

## Load the API package
```dart
import 'package:openapi_client/api.dart';
```

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getServerMotd**](ServerOptionsApi.md#getservermotd) | **GET** /servers/{serverId}/options/motd/ | Get server MOTD
[**getServerRam**](ServerOptionsApi.md#getserverram) | **GET** /servers/{serverId}/options/ram/ | Get server ram
[**postServerMotd**](ServerOptionsApi.md#postservermotd) | **POST** /servers/{serverId}/options/motd/ | Change server MOTD
[**postServerRam**](ServerOptionsApi.md#postserverram) | **POST** /servers/{serverId}/options/ram/ | Change server ram


# **getServerMotd**
> GetServerMotd200Response getServerMotd(serverId)

Get server MOTD

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerOptionsApi();
final serverId = serverId_example; // String | Unique server ID

try {
    final result = api_instance.getServerMotd(serverId);
    print(result);
} catch (e) {
    print('Exception when calling ServerOptionsApi->getServerMotd: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 

### Return type

[**GetServerMotd200Response**](GetServerMotd200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getServerRam**
> GetServerRam200Response getServerRam(serverId)

Get server ram

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerOptionsApi();
final serverId = serverId_example; // String | Unique server ID

try {
    final result = api_instance.getServerRam(serverId);
    print(result);
} catch (e) {
    print('Exception when calling ServerOptionsApi->getServerRam: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 

### Return type

[**GetServerRam200Response**](GetServerRam200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postServerMotd**
> GetServerMotd200Response postServerMotd(serverId, postServerMotdRequest)

Change server MOTD

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerOptionsApi();
final serverId = serverId_example; // String | Unique server ID
final postServerMotdRequest = PostServerMotdRequest(); // PostServerMotdRequest | 

try {
    final result = api_instance.postServerMotd(serverId, postServerMotdRequest);
    print(result);
} catch (e) {
    print('Exception when calling ServerOptionsApi->postServerMotd: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **postServerMotdRequest** | [**PostServerMotdRequest**](PostServerMotdRequest.md)|  | 

### Return type

[**GetServerMotd200Response**](GetServerMotd200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postServerRam**
> GetServerRam200Response postServerRam(serverId, postServerRamRequest)

Change server ram

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerOptionsApi();
final serverId = serverId_example; // String | Unique server ID
final postServerRamRequest = PostServerRamRequest(); // PostServerRamRequest | 

try {
    final result = api_instance.postServerRam(serverId, postServerRamRequest);
    print(result);
} catch (e) {
    print('Exception when calling ServerOptionsApi->postServerRam: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **postServerRamRequest** | [**PostServerRamRequest**](PostServerRamRequest.md)|  | 

### Return type

[**GetServerRam200Response**](GetServerRam200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

