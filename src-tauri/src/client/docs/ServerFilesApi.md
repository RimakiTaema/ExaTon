# \ServerFilesApi

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**delete_file**](ServerFilesApi.md#delete_file) | **DELETE** /servers/{serverId}/files/data/{path}/ | Delete a file or directory
[**get_config_file_data**](ServerFilesApi.md#get_config_file_data) | **GET** /servers/{serverId}/files/config/{path}/ | Get config file data
[**get_file_content**](ServerFilesApi.md#get_file_content) | **GET** /servers/{serverId}/files/data/{path}/ | Get file content
[**get_file_info**](ServerFilesApi.md#get_file_info) | **GET** /servers/{serverId}/files/info/{path}/ | Get file info
[**post_config_file_data**](ServerFilesApi.md#post_config_file_data) | **POST** /servers/{serverId}/files/config/{path}/ | Update config file
[**put_file_data**](ServerFilesApi.md#put_file_data) | **PUT** /servers/{serverId}/files/data/{path}/ | Write file content or create a directory



## delete_file

> models::GetStartServer200Response delete_file(server_id, path)
Delete a file or directory

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**path** | **String** | File path | [required] |

### Return type

[**models::GetStartServer200Response**](getStartServer_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_config_file_data

> models::GetConfigFileData200Response get_config_file_data(server_id, path)
Get config file data

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**path** | **String** | File path | [required] |

### Return type

[**models::GetConfigFileData200Response**](getConfigFileData_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_file_content

> std::path::PathBuf get_file_content(server_id, path)
Get file content

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**path** | **String** | File path | [required] |

### Return type

[**std::path::PathBuf**](std::path::PathBuf.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/octet-stream, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_file_info

> models::GetFileInfo200Response get_file_info(server_id, path)
Get file info

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**path** | **String** | File path | [required] |

### Return type

[**models::GetFileInfo200Response**](getFileInfo_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## post_config_file_data

> models::GetConfigFileData200Response post_config_file_data(server_id, path, request_body)
Update config file

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**path** | **String** | File path | [required] |
**request_body** | Option<[**std::collections::HashMap<String, serde_json::Value>**](SerdeJson__Value.md)> |  |  |

### Return type

[**models::GetConfigFileData200Response**](getConfigFileData_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## put_file_data

> models::GetStartServer200Response put_file_data(server_id, path, body)
Write file content or create a directory

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**path** | **String** | File path | [required] |
**body** | Option<**std::path::PathBuf**> |  |  |

### Return type

[**models::GetStartServer200Response**](getStartServer_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/octet-stream, inode/directory
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

