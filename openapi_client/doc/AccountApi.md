# openapi_client.api.AccountApi

## Load the API package
```dart
import 'package:openapi_client/api.dart';
```

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAccount**](AccountApi.md#getaccount) | **GET** /account/ | Get account info


# **getAccount**
> GetAccount200Response getAccount()

Get account info

### Example
```dart
import 'package:openapi_client/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AccountApi();

try {
    final result = api_instance.getAccount();
    print(result);
} catch (e) {
    print('Exception when calling AccountApi->getAccount: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetAccount200Response**](GetAccount200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

