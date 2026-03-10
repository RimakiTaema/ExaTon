# \ServerPlayersApi

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**delete_player_list**](ServerPlayersApi.md#delete_player_list) | **DELETE** /servers/{serverId}/playerlists/{list}/ | Remove entries from player list
[**get_player_list**](ServerPlayersApi.md#get_player_list) | **GET** /servers/{serverId}/playerlists/{list}/ | Get player list contents
[**get_player_lists**](ServerPlayersApi.md#get_player_lists) | **GET** /servers/{serverId}/playerlists/ | Get available player lists
[**put_player_list**](ServerPlayersApi.md#put_player_list) | **PUT** /servers/{serverId}/playerlists/{list}/ | Add entries to player list



## delete_player_list

> models::GetPlayerList200Response delete_player_list(server_id, list, delete_player_list_request_body)
Remove entries from player list

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**list** | **String** | Player list name | [required] |
**delete_player_list_request_body** | Option<[**DeletePlayerListRequestBody**](DeletePlayerListRequestBody.md)> |  |  |

### Return type

[**models::GetPlayerList200Response**](getPlayerList_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_player_list

> models::GetPlayerList200Response get_player_list(server_id, list)
Get player list contents

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**list** | **String** | Player list name | [required] |

### Return type

[**models::GetPlayerList200Response**](getPlayerList_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_player_lists

> models::GetPlayerLists200Response get_player_lists(server_id)
Get available player lists

A player list is a list of players such as the whitelist, ops or bans. Player list entries are usually usernames, but might be something else, e.g. IPs in the banned-ips list. All player list operations are storage operations that might take a while, so try to reduce the amount of requests and combine actions when possible (e.g. adding/deleting multiple entries at once). Player lists are also cached and might not immediately return new results when changed through other methods.

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |

### Return type

[**models::GetPlayerLists200Response**](getPlayerLists_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## put_player_list

> models::GetPlayerList200Response put_player_list(server_id, list, put_player_list_request_body)
Add entries to player list

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**server_id** | **String** | Unique server ID | [required] |
**list** | **String** | Player list name | [required] |
**put_player_list_request_body** | Option<[**PutPlayerListRequestBody**](PutPlayerListRequestBody.md)> |  |  |

### Return type

[**models::GetPlayerList200Response**](getPlayerList_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

