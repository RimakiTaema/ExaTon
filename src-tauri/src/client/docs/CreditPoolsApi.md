# \CreditPoolsApi

All URIs are relative to *https://api.exaroton.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**get_credit_pool**](CreditPoolsApi.md#get_credit_pool) | **GET** /billing/pools/{poolId}/ | Get a credit pool
[**get_credit_pool_members**](CreditPoolsApi.md#get_credit_pool_members) | **GET** /billing/pools/{poolId}/members/ | Get all members in a credit pool
[**get_credit_pool_servers**](CreditPoolsApi.md#get_credit_pool_servers) | **GET** /billing/pools/{poolId}/servers/ | Get all servers in a credit pool
[**get_credit_pools**](CreditPoolsApi.md#get_credit_pools) | **GET** /billing/pools/ | List all credit pools



## get_credit_pool

> models::GetCreditPool200Response get_credit_pool(pool_id)
Get a credit pool

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**pool_id** | **String** | Unique credit pool ID | [required] |

### Return type

[**models::GetCreditPool200Response**](getCreditPool_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_credit_pool_members

> models::GetCreditPoolMembers200Response get_credit_pool_members(pool_id)
Get all members in a credit pool

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**pool_id** | **String** | Unique credit pool ID | [required] |

### Return type

[**models::GetCreditPoolMembers200Response**](getCreditPoolMembers_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_credit_pool_servers

> models::GetServers200Response get_credit_pool_servers(pool_id)
Get all servers in a credit pool

### Parameters


Name | Type | Description  | Required | Notes
------------- | ------------- | ------------- | ------------- | -------------
**pool_id** | **String** | Unique credit pool ID | [required] |

### Return type

[**models::GetServers200Response**](getServers_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


## get_credit_pools

> models::GetCreditPools200Response get_credit_pools()
List all credit pools

### Parameters

This endpoint does not need any parameter.

### Return type

[**models::GetCreditPools200Response**](getCreditPools_200_response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

