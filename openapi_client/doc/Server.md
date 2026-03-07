# openapi.model.Server

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Unique server ID | [optional] 
**name** | **String** | Server name | [optional] 
**address** | **String** | Full server address | [optional] 
**motd** | **String** | The MOTD of the server | [optional] 
**status** | [**ServerStatus**](ServerStatus.md) |  | [optional] 
**host** | **String** | Host machine the server is running on. Only available if the server is online. | [optional] 
**port** | **int** | Port the server is listening on. Only available if the server is online. | [optional] 
**players** | [**ServerPlayers**](ServerPlayers.md) |  | [optional] 
**software** | [**ServerSoftware**](ServerSoftware.md) |  | [optional] 
**shared** | **bool** | Whether the server is accessed via the Share Access feature | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


