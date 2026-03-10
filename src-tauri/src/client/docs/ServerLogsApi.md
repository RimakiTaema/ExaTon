# \ServerLogsApi

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**get_server_log**](ServerLogsApi.md#get_server_log) | **GET** /servers/{serverId}/logs/ | Get a server log
[**share_server_log**](ServerLogsApi.md#share_server_log) | **GET** /servers/{serverId}/logs/share/ | Upload a server log to mclo.gs



## get_server_log

> models::GetServerLog200Response get_server_log(server_id)
Get a server log

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |

### Return type

[**models::GetServerLog200Response**](getServerLog_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## share_server_log

> models::ShareServerLog200Response share_server_log(server_id)
Upload a server log to mclo.gs

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |

### Return type

[**models::ShareServerLog200Response**](shareServerLog_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

