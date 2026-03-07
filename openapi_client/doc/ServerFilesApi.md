# openapi.api.ServerFilesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteFile**](ServerFilesApi.md#deletefile) | **DELETE** /servers/{serverId}/files/data/{path}/ | Delete a file or directory
[**getConfigFileData**](ServerFilesApi.md#getconfigfiledata) | **GET** /servers/{serverId}/files/config/{path}/ | Get config file data
[**getFileContent**](ServerFilesApi.md#getfilecontent) | **GET** /servers/{serverId}/files/data/{path}/ | Get file content
[**getFileInfo**](ServerFilesApi.md#getfileinfo) | **GET** /servers/{serverId}/files/info/{path}/ | Get file info
[**postConfigFileData**](ServerFilesApi.md#postconfigfiledata) | **POST** /servers/{serverId}/files/config/{path}/ | Update config file
[**putFileData**](ServerFilesApi.md#putfiledata) | **PUT** /servers/{serverId}/files/data/{path}/ | Write file content or create a directory


# **deleteFile**
> GetStartServer200Response deleteFile(serverId, path)

Delete a file or directory

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getServerFilesApi();
final String serverId = serverId_example; // String | Unique server ID
final String path = path_example; // String | File path

try {
    final response = api.deleteFile(serverId, path);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ServerFilesApi->deleteFile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **path** | **String**| File path | 

### Return type

[**GetStartServer200Response**](GetStartServer200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getConfigFileData**
> GetConfigFileData200Response getConfigFileData(serverId, path)

Get config file data

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getServerFilesApi();
final String serverId = serverId_example; // String | Unique server ID
final String path = path_example; // String | File path

try {
    final response = api.getConfigFileData(serverId, path);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ServerFilesApi->getConfigFileData: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **path** | **String**| File path | 

### Return type

[**GetConfigFileData200Response**](GetConfigFileData200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFileContent**
> Uint8List getFileContent(serverId, path)

Get file content

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getServerFilesApi();
final String serverId = serverId_example; // String | Unique server ID
final String path = path_example; // String | File path

try {
    final response = api.getFileContent(serverId, path);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ServerFilesApi->getFileContent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **path** | **String**| File path | 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/octet-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFileInfo**
> GetFileInfo200Response getFileInfo(serverId, path)

Get file info

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getServerFilesApi();
final String serverId = serverId_example; // String | Unique server ID
final String path = path_example; // String | File path

try {
    final response = api.getFileInfo(serverId, path);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ServerFilesApi->getFileInfo: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **path** | **String**| File path | 

### Return type

[**GetFileInfo200Response**](GetFileInfo200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postConfigFileData**
> GetConfigFileData200Response postConfigFileData(serverId, path, requestBody)

Update config file

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getServerFilesApi();
final String serverId = serverId_example; // String | Unique server ID
final String path = path_example; // String | File path
final BuiltMap<String, JsonObject> requestBody = Object; // BuiltMap<String, JsonObject> | 

try {
    final response = api.postConfigFileData(serverId, path, requestBody);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ServerFilesApi->postConfigFileData: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **path** | **String**| File path | 
 **requestBody** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)|  | [optional] 

### Return type

[**GetConfigFileData200Response**](GetConfigFileData200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putFileData**
> GetStartServer200Response putFileData(serverId, path, body)

Write file content or create a directory

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getServerFilesApi();
final String serverId = serverId_example; // String | Unique server ID
final String path = path_example; // String | File path
final MultipartFile body = BINARY_DATA_HERE; // MultipartFile | 

try {
    final response = api.putFileData(serverId, path, body);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ServerFilesApi->putFileData: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **serverId** | **String**| Unique server ID | 
 **path** | **String**| File path | 
 **body** | **MultipartFile**|  | [optional] 

### Return type

[**GetStartServer200Response**](GetStartServer200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/octet-stream, inode/directory
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

