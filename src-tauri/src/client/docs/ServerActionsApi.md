# \ServerActionsApi

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**extend_server_stop_time**](ServerActionsApi.md#extend_server_stop_time) | **POST** /servers/{serverId}/extend-time/ | Extend server stop timer
[**get_start_server**](ServerActionsApi.md#get_start_server) | **GET** /servers/{serverId}/start/ | Start a server
[**post_server_command**](ServerActionsApi.md#post_server_command) | **POST** /servers/{serverId}/command/ | Execute a server command
[**post_start_server**](ServerActionsApi.md#post_start_server) | **POST** /servers/{serverId}/start/ | Start a server with own credits
[**restart_server**](ServerActionsApi.md#restart_server) | **GET** /servers/{serverId}/restart/ | Restart a server
[**stop_server**](ServerActionsApi.md#stop_server) | **GET** /servers/{serverId}/stop/ | Stop a server



## extend_server_stop_time

> models::GetStartServer200Response extend_server_stop_time(server_id, extend_server_stop_time_request_body)
Extend server stop timer

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**extend_server_stop_time_request_body** | Option<[**ExtendServerStopTimeRequestBody**](ExtendServerStopTimeRequestBody.md)> |  |  |

### Return type

[**models::GetStartServer200Response**](getStartServer_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_start_server

> models::GetStartServer200Response get_start_server(server_id)
Start a server

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |

### Return type

[**models::GetStartServer200Response**](getStartServer_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## post_server_command

> models::GetStartServer200Response post_server_command(server_id, post_server_command_request_body)
Execute a server command

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**post_server_command_request_body** | Option<[**PostServerCommandRequestBody**](PostServerCommandRequestBody.md)> |  |  |

### Return type

[**models::GetStartServer200Response**](getStartServer_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## post_start_server

> models::GetStartServer200Response post_start_server(server_id, post_start_server_request)
Start a server with own credits

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**post_start_server_request** | Option<[**PostStartServerRequest**](PostStartServerRequest.md)> |  |  |

### Return type

[**models::GetStartServer200Response**](getStartServer_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## restart_server

> models::GetStartServer200Response restart_server(server_id)
Restart a server

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |

### Return type

[**models::GetStartServer200Response**](getStartServer_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## stop_server

> models::GetStartServer200Response stop_server(server_id)
Stop a server

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |

### Return type

[**models::GetStartServer200Response**](getStartServer_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

