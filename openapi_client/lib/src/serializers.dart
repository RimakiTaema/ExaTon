//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:openapi/src/date_serializer.dart';
import 'package:openapi/src/model/date.dart';

import 'package:openapi/src/model/config_file_option.dart';
import 'package:openapi/src/model/config_file_option_value.dart';
import 'package:openapi/src/model/credit_pool.dart';
import 'package:openapi/src/model/credit_pool_member.dart';
import 'package:openapi/src/model/delete_player_list_request_body.dart';
import 'package:openapi/src/model/error.dart';
import 'package:openapi/src/model/extend_server_stop_time_request_body.dart';
import 'package:openapi/src/model/file_info.dart';
import 'package:openapi/src/model/get_account200_response.dart';
import 'package:openapi/src/model/get_account200_response_data.dart';
import 'package:openapi/src/model/get_config_file_data200_response.dart';
import 'package:openapi/src/model/get_credit_pool200_response.dart';
import 'package:openapi/src/model/get_credit_pool_members200_response.dart';
import 'package:openapi/src/model/get_credit_pools200_response.dart';
import 'package:openapi/src/model/get_file_info200_response.dart';
import 'package:openapi/src/model/get_player_list200_response.dart';
import 'package:openapi/src/model/get_player_lists200_response.dart';
import 'package:openapi/src/model/get_server200_response.dart';
import 'package:openapi/src/model/get_server_log200_response.dart';
import 'package:openapi/src/model/get_server_log200_response_data.dart';
import 'package:openapi/src/model/get_server_motd200_response.dart';
import 'package:openapi/src/model/get_server_motd200_response_data.dart';
import 'package:openapi/src/model/get_server_ram200_response.dart';
import 'package:openapi/src/model/get_server_ram200_response_data.dart';
import 'package:openapi/src/model/get_servers200_response.dart';
import 'package:openapi/src/model/get_start_server200_response.dart';
import 'package:openapi/src/model/post_server_command_request_body.dart';
import 'package:openapi/src/model/post_server_motd_request.dart';
import 'package:openapi/src/model/post_server_ram_request.dart';
import 'package:openapi/src/model/post_start_server_request.dart';
import 'package:openapi/src/model/put_player_list_request_body.dart';
import 'package:openapi/src/model/server.dart';
import 'package:openapi/src/model/server_players.dart';
import 'package:openapi/src/model/server_software.dart';
import 'package:openapi/src/model/server_status.dart';
import 'package:openapi/src/model/share_server_log200_response.dart';
import 'package:openapi/src/model/share_server_log200_response_data.dart';

part 'serializers.g.dart';

@SerializersFor([
  ConfigFileOption,
  ConfigFileOptionValue,
  CreditPool,
  CreditPoolMember,
  DeletePlayerListRequestBody,
  Error,
  ExtendServerStopTimeRequestBody,
  FileInfo,
  GetAccount200Response,
  GetAccount200ResponseData,
  GetConfigFileData200Response,
  GetCreditPool200Response,
  GetCreditPoolMembers200Response,
  GetCreditPools200Response,
  GetFileInfo200Response,
  GetPlayerList200Response,
  GetPlayerLists200Response,
  GetServer200Response,
  GetServerLog200Response,
  GetServerLog200ResponseData,
  GetServerMotd200Response,
  GetServerMotd200ResponseData,
  GetServerRam200Response,
  GetServerRam200ResponseData,
  GetServers200Response,
  GetStartServer200Response,
  PostServerCommandRequestBody,
  PostServerMotdRequest,
  PostServerRamRequest,
  PostStartServerRequest,
  PutPlayerListRequestBody,
  Server,
  ServerPlayers,
  ServerSoftware,
  ServerStatus,
  ShareServerLog200Response,
  ShareServerLog200ResponseData,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
        () => MapBuilder<String, JsonObject>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
