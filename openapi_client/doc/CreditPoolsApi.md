# openapi_client.api.CreditPoolsApi

## Load the API package
```dart
import 'package:openapi_client/api.dart';
```

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getCreditPool**](CreditPoolsApi.md#getcreditpool) | **GET** /billing/pools/{poolId}/ | Get a credit pool
[**getCreditPoolMembers**](CreditPoolsApi.md#getcreditpoolmembers) | **GET** /billing/pools/{poolId}/members/ | Get all members in a credit pool
[**getCreditPoolServers**](CreditPoolsApi.md#getcreditpoolservers) | **GET** /billing/pools/{poolId}/servers/ | Get all servers in a credit pool
[**getCreditPools**](CreditPoolsApi.md#getcreditpools) | **GET** /billing/pools/ | List all credit pools


# **getCreditPool**
> GetCreditPool200Response getCreditPool(poolId)

Get a credit pool

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CreditPoolsApi();
final poolId = poolId_example; // String | Unique credit pool ID

try {
    final result = api_instance.getCreditPool(poolId);
    print(result);
} catch (e) {
    print('Exception when calling CreditPoolsApi->getCreditPool: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **poolId** | **String**| Unique credit pool ID | 

### Return type

[**GetCreditPool200Response**](GetCreditPool200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCreditPoolMembers**
> GetCreditPoolMembers200Response getCreditPoolMembers(poolId)

Get all members in a credit pool

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CreditPoolsApi();
final poolId = poolId_example; // String | Unique credit pool ID

try {
    final result = api_instance.getCreditPoolMembers(poolId);
    print(result);
} catch (e) {
    print('Exception when calling CreditPoolsApi->getCreditPoolMembers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **poolId** | **String**| Unique credit pool ID | 

### Return type

[**GetCreditPoolMembers200Response**](GetCreditPoolMembers200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCreditPoolServers**
> GetServers200Response getCreditPoolServers(poolId)

Get all servers in a credit pool

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CreditPoolsApi();
final poolId = poolId_example; // String | Unique credit pool ID

try {
    final result = api_instance.getCreditPoolServers(poolId);
    print(result);
} catch (e) {
    print('Exception when calling CreditPoolsApi->getCreditPoolServers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **poolId** | **String**| Unique credit pool ID | 

### Return type

[**GetServers200Response**](GetServers200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCreditPools**
> GetCreditPools200Response getCreditPools()

List all credit pools

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CreditPoolsApi();

try {
    final result = api_instance.getCreditPools();
    print(result);
} catch (e) {
    print('Exception when calling CreditPoolsApi->getCreditPools: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetCreditPools200Response**](GetCreditPools200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

