# openapi.api.ServerOptionsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
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
import 'package:openapi/api.dart';

final api = Openapi().getServerOptionsApi();
final String serverId = serverId_example; // String | Unique server ID

try {
    final response = api.getServerMotd(serverId);
    print(response);
} on DioException catch (e) {
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
import 'package:openapi/api.dart';

final api = Openapi().getServerOptionsApi();
final String serverId = serverId_example; // String | Unique server ID

try {
    final response = api.getServerRam(serverId);
    print(response);
} on DioException catch (e) {
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
import 'package:openapi/api.dart';

final api = Openapi().getServerOptionsApi();
final String serverId = serverId_example; // String | Unique server ID
final PostServerMotdRequest postServerMotdRequest = ; // PostServerMotdRequest | 

try {
    final response = api.postServerMotd(serverId, postServerMotdRequest);
    print(response);
} on DioException catch (e) {
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
import 'package:openapi/api.dart';

final api = Openapi().getServerOptionsApi();
final String serverId = serverId_example; // String | Unique server ID
final PostServerRamRequest postServerRamRequest = ; // PostServerRamRequest | 

try {
    final response = api.postServerRam(serverId, postServerRamRequest);
    print(response);
} on DioException catch (e) {
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

