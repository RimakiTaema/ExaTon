//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'lib/api/account_api.dart';
part 'lib/api/credit_pools_api.dart';
part 'lib/api/server_actions_api.dart';
part 'lib/api/server_files_api.dart';
part 'lib/api/server_logs_api.dart';
part 'lib/api/server_options_api.dart';
part 'lib/api/server_players_api.dart';
part 'lib/api/servers_api.dart';

part 'lib/model/config_file_option.dart';
part 'lib/model/config_file_option_value.dart';
part 'lib/model/credit_pool.dart';
part 'lib/model/credit_pool_member.dart';
part 'lib/model/delete_player_list_request_body.dart';
part 'lib/model/error.dart';
part 'lib/model/extend_server_stop_time_request_body.dart';
part 'lib/model/file_info.dart';
part 'lib/model/get_account200_response.dart';
part 'lib/model/get_account200_response_data.dart';
part 'lib/model/get_config_file_data200_response.dart';
part 'lib/model/get_credit_pool200_response.dart';
part 'lib/model/get_credit_pool_members200_response.dart';
part 'lib/model/get_credit_pools200_response.dart';
part 'lib/model/get_file_info200_response.dart';
part 'lib/model/get_player_list200_response.dart';
part 'lib/model/get_player_lists200_response.dart';
part 'lib/model/get_server200_response.dart';
part 'lib/model/get_server_log200_response.dart';
part 'lib/model/get_server_log200_response_data.dart';
part 'lib/model/get_server_motd200_response.dart';
part 'lib/model/get_server_motd200_response_data.dart';
part 'lib/model/get_server_ram200_response.dart';
part 'lib/model/get_server_ram200_response_data.dart';
part 'lib/model/get_servers200_response.dart';
part 'lib/model/get_start_server200_response.dart';
part 'lib/model/post_server_command_request_body.dart';
part 'lib/model/post_server_motd_request.dart';
part 'lib/model/post_server_ram_request.dart';
part 'lib/model/post_start_server_request.dart';
part 'lib/model/put_player_list_request_body.dart';
part 'lib/model/server.dart';
part 'lib/model/server_players.dart';
part 'lib/model/server_software.dart';
part 'lib/model/server_status.dart';
part 'lib/model/share_server_log200_response.dart';
part 'lib/model/share_server_log200_response_data.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
