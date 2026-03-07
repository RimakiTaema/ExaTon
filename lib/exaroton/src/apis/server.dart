import 'package:openapi_client/api.dart';

import '../env/env.dart';

class GetServers {
  final String token;

  GetServers({required this.token});

  Future<GetServers200Response> runRaw() async {
    final apiClient = ApiClient(basePath: Env.baseUrl);
    apiClient.addDefaultHeader('Authorization', 'Bearer $token');

    final serversApi = ServersApi(apiClient);
    final response = await serversApi.getServers();
    if (response == null) {
      throw Exception('Failed to get servers');
    }

    return response;
  }

  Future<List<Server>> run() async {
    final response = await runRaw();
    return response.data;
  }
}

class GetServer {
  final String token;
  final String serverId;

  GetServer({
    required this.token,
    required this.serverId,
  });

  Future<GetServer200Response> run() async {
    final apiClient = ApiClient(basePath: Env.baseUrl);
    apiClient.addDefaultHeader('Authorization', 'Bearer $token');

    final serversApi = ServersApi(apiClient);
    final response = await serversApi.getServer(serverId);
    if (response == null) {
      throw Exception('Failed to get server: $serverId');
    }

    return response;
  }

  Future<ServerOverview> runOverview() async {
    final response = await run();
    return ServerOverview.fromResponse(response);
  }
}

class ServerActions {
  final String token;
  final String serverId;

  ServerActions({
    required this.token,
    required this.serverId,
  });

  ApiClient _client() {
    final apiClient = ApiClient(basePath: Env.baseUrl);
    apiClient.addDefaultHeader('Authorization', 'Bearer $token');
    return apiClient;
  }

  Future<GetStartServer200Response> start() async {
    final response = await ServerActionsApi(_client()).postStartServer(serverId);
    if (response == null) {
      throw Exception('Failed to start server: $serverId');
    }
    return response;
  }

  Future<GetStartServer200Response> restart() async {
    final response = await ServerActionsApi(_client()).restartServer(serverId);
    if (response == null) {
      throw Exception('Failed to restart server: $serverId');
    }
    return response;
  }

  Future<GetStartServer200Response> stop() async {
    final response = await ServerActionsApi(_client()).stopServer(serverId);
    if (response == null) {
      throw Exception('Failed to stop server: $serverId');
    }
    return response;
  }
}

class GetServerRam {
  final String token;
  final String serverId;

  GetServerRam({
    required this.token,
    required this.serverId,
  });

  Future<int?> run() async {
    final apiClient = ApiClient(basePath: Env.baseUrl);
    apiClient.addDefaultHeader('Authorization', 'Bearer $token');

    final response = await ServerOptionsApi(apiClient).getServerRam(serverId);
    return response?.data?.ram;
  }
}

class ServerOverview {
  final String? id;
  final String? name;
  final String? address;
  final String? motd;
  final int? statusCode;
  final String? status;
  final String action;
  final String? software;
  final String? version;
  final String? host;
  final int? port;
  final int? playersOnline;
  final int? playersMax;
  final bool? shared;

  const ServerOverview({
    this.id,
    this.name,
    this.address,
    this.motd,
    this.statusCode,
    this.status,
    required this.action,
    this.software,
    this.version,
    this.host,
    this.port,
    this.playersOnline,
    this.playersMax,
    this.shared,
  });

  factory ServerOverview.fromResponse(GetServer200Response response) {
    final server = response.data;
    final statusCode = server?.status?.value;

    return ServerOverview(
      id: server?.id,
      name: server?.name,
      address: server?.address,
      motd: server?.motd,
      statusCode: statusCode,
      status: _statusName(statusCode),
      action: _nextAction(statusCode),
      software: server?.software?.name,
      version: server?.software?.version,
      host: server?.host,
      port: server?.port,
      playersOnline: server?.players?.count,
      playersMax: server?.players?.max,
      shared: server?.shared,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'motd': motd,
        'statusCode': statusCode,
        'status': status,
        'action': action,
        'software': software,
        'version': version,
        'host': host,
        'port': port,
        'playersOnline': playersOnline,
        'playersMax': playersMax,
        'shared': shared,
      };
}

String? _statusName(int? code) {
  switch (code) {
    case 0:
      return 'OFFLINE';
    case 1:
      return 'ONLINE';
    case 2:
      return 'STARTING';
    case 3:
      return 'STOPPING';
    case 4:
      return 'RESTARTING';
    case 5:
      return 'SAVING';
    case 6:
      return 'LOADING';
    case 7:
      return 'CRASHED';
    case 8:
      return 'PENDING';
    case 9:
      return 'TRANSFERRING';
    case 10:
      return 'PREPARING';
    default:
      return null;
  }
}

String _nextAction(int? code) {
  switch (code) {
    case 0:
    case 7:
      return 'start';
    case 1:
      return 'stop';
    default:
      return 'wait';
  }
}
