# \ServerOptionsApi

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**get_server_motd**](ServerOptionsApi.md#get_server_motd) | **GET** /servers/{serverId}/options/motd/ | Get server MOTD
[**get_server_ram**](ServerOptionsApi.md#get_server_ram) | **GET** /servers/{serverId}/options/ram/ | Get server ram
[**post_server_motd**](ServerOptionsApi.md#post_server_motd) | **POST** /servers/{serverId}/options/motd/ | Change server MOTD
[**post_server_ram**](ServerOptionsApi.md#post_server_ram) | **POST** /servers/{serverId}/options/ram/ | Change server ram



## get_server_motd

> models::GetServerMotd200Response get_server_motd(server_id)
Get server MOTD

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |

### Return type

[**models::GetServerMotd200Response**](getServerMotd_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_server_ram

> models::GetServerRam200Response get_server_ram(server_id)
Get server ram

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |

### Return type

[**models::GetServerRam200Response**](getServerRam_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## post_server_motd

> models::GetServerMotd200Response post_server_motd(server_id, post_server_motd_request)
Change server MOTD

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**post_server_motd_request** | [**PostServerMotdRequest**](PostServerMotdRequest.md) |  | [required] |

### Return type

[**models::GetServerMotd200Response**](getServerMotd_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## post_server_ram

> models::GetServerRam200Response post_server_ram(server_id, post_server_ram_request)
Change server ram

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**post_server_ram_request** | [**PostServerRamRequest**](PostServerRamRequest.md) |  | [required] |

### Return type

[**models::GetServerRam200Response**](getServerRam_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

