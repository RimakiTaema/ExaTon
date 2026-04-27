# Server

## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | Option<**String**> | Unique server ID | [optional]
**name** | Option<**String**> | Server name | [optional]
**address** | Option<**String**> | Full server address | [optional]
**motd** | Option<**String**> | The MOTD of the server | [optional]
**status** | Option<[**models::ServerStatus**](ServerStatus.md)> |  | [optional]
**host** | Option<**String**> | Host machine the server is running on. Only available if the server is online. | [optional]
**port** | Option<**i32**> | Port the server is listening on. Only available if the server is online. | [optional]
**players** | Option<[**models::ServerPlayers**](ServerPlayers.md)> |  | [optional]
**software** | Option<[**models::ServerSoftware**](ServerSoftware.md)> |  | [optional]
**shared** | Option<**bool**> | Whether the server is accessed via the Share Access feature | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


