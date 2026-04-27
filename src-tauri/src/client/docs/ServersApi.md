# \ServersApi

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**get_server**](ServersApi.md#get_server) | **GET** /servers/{serverId}/ | Get a server
[**get_servers**](ServersApi.md#get_servers) | **GET** /servers/ | Get all servers



## get_server

> models::GetServer200Response get_server(server_id)
Get a server

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |

### Return type

[**models::GetServer200Response**](getServer_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_servers

> models::GetServers200Response get_servers()
Get all servers

### Parameters

This endpoint does not need any parameter.

### Return type

[**models::GetServers200Response**](getServers_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

