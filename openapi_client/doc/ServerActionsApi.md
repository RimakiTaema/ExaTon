# openapi_client.api.ServerActionsApi

## Load the API package
```dart
import 'package:openapi_client/api.dart';
```

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**extendServerStopTime**](ServerActionsApi.md#extendserverstoptime) | **POST** /servers/{serverId}/extend-time/ | Extend server stop timer
[**getStartServer**](ServerActionsApi.md#getstartserver) | **GET** /servers/{serverId}/start/ | Start a server
[**postServerCommand**](ServerActionsApi.md#postservercommand) | **POST** /servers/{serverId}/command/ | Execute a server command
[**postStartServer**](ServerActionsApi.md#poststartserver) | **POST** /servers/{serverId}/start/ | Start a server with own credits
[**restartServer**](ServerActionsApi.md#restartserver) | **GET** /servers/{serverId}/restart/ | Restart a server
[**stopServer**](ServerActionsApi.md#stopserver) | **GET** /servers/{serverId}/stop/ | Stop a server


# **extendServerStopTime**
> GetStartServer200Response extendServerStopTime(serverId, extendServerStopTimeRequestBody)

Extend server stop timer

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerActionsApi();
final serverId = serverId_example; // String | Unique server ID
final extendServerStopTimeRequestBody = ExtendServerStopTimeRequestBody(); // ExtendServerStopTimeRequestBody | 

try {
    final result = api_instance.extendServerStopTime(serverId, extendServerStopTimeRequestBody);
    print(result);
} catch (e) {
    print('Exception when calling ServerActionsApi->extendServerStopTime: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **extendServerStopTimeRequestBody** | [**ExtendServerStopTimeRequestBody**](ExtendServerStopTimeRequestBody.md)|  | [optional] 

### Return type

[**GetStartServer200Response**](GetStartServer200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStartServer**
> GetStartServer200Response getStartServer(serverId)

Start a server

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerActionsApi();
final serverId = serverId_example; // String | Unique server ID

try {
    final result = api_instance.getStartServer(serverId);
    print(result);
} catch (e) {
    print('Exception when calling ServerActionsApi->getStartServer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 

### Return type

[**GetStartServer200Response**](GetStartServer200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postServerCommand**
> GetStartServer200Response postServerCommand(serverId, postServerCommandRequestBody)

Execute a server command

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerActionsApi();
final serverId = serverId_example; // String | Unique server ID
final postServerCommandRequestBody = PostServerCommandRequestBody(); // PostServerCommandRequestBody | 

try {
    final result = api_instance.postServerCommand(serverId, postServerCommandRequestBody);
    print(result);
} catch (e) {
    print('Exception when calling ServerActionsApi->postServerCommand: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **postServerCommandRequestBody** | [**PostServerCommandRequestBody**](PostServerCommandRequestBody.md)|  | [optional] 

### Return type

[**GetStartServer200Response**](GetStartServer200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postStartServer**
> GetStartServer200Response postStartServer(serverId, postStartServerRequest)

Start a server with own credits

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerActionsApi();
final serverId = serverId_example; // String | Unique server ID
final postStartServerRequest = PostStartServerRequest(); // PostStartServerRequest | 

try {
    final result = api_instance.postStartServer(serverId, postStartServerRequest);
    print(result);
} catch (e) {
    print('Exception when calling ServerActionsApi->postStartServer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **postStartServerRequest** | [**PostStartServerRequest**](PostStartServerRequest.md)|  | [optional] 

### Return type

[**GetStartServer200Response**](GetStartServer200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **restartServer**
> GetStartServer200Response restartServer(serverId)

Restart a server

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerActionsApi();
final serverId = serverId_example; // String | Unique server ID

try {
    final result = api_instance.restartServer(serverId);
    print(result);
} catch (e) {
    print('Exception when calling ServerActionsApi->restartServer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 

### Return type

[**GetStartServer200Response**](GetStartServer200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **stopServer**
> GetStartServer200Response stopServer(serverId)

Stop a server

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = ServerActionsApi();
final serverId = serverId_example; // String | Unique server ID

try {
    final result = api_instance.stopServer(serverId);
    print(result);
} catch (e) {
    print('Exception when calling ServerActionsApi->stopServer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 

### Return type

[**GetStartServer200Response**](GetStartServer200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

