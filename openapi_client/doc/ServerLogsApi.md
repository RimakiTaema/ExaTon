# openapi.api.ServerLogsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getServerLog**](ServerLogsApi.md#getserverlog) | **GET** /servers/{serverId}/logs/ | Get a server log
[**shareServerLog**](ServerLogsApi.md#shareserverlog) | **GET** /servers/{serverId}/logs/share/ | Upload a server log to mclo.gs


# **getServerLog**
> GetServerLog200Response getServerLog(serverId)

Get a server log

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getServerLogsApi();
final String serverId = serverId_example; // String | Unique server ID

try {
    final response = api.getServerLog(serverId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ServerLogsApi->getServerLog: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 

### Return type

[**GetServerLog200Response**](GetServerLog200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **shareServerLog**
> ShareServerLog200Response shareServerLog(serverId)

Upload a server log to mclo.gs

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getServerLogsApi();
final String serverId = serverId_example; // String | Unique server ID

try {
    final response = api.shareServerLog(serverId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ServerLogsApi->shareServerLog: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 

### Return type

[**ShareServerLog200Response**](ShareServerLog200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

