// Models for the exaroton REST API and websocket.
//
// Written against openapi.yaml (repo root) and checked by hand. Every parser is
// lenient: a missing or wrongly typed field falls back to a safe default
// rather than throwing, because the API adds fields over time.

double _toDouble(Object? v, [double fallback = 0]) =>
    v is num ? v.toDouble() : (v is String ? double.tryParse(v) ?? fallback : fallback);

int _toInt(Object? v, [int fallback = 0]) =>
    v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? fallback : fallback);

String _toStr(Object? v, [String fallback = '']) => v is String ? v : fallback;

Map<String, dynamic> _map(Object? v) => v is Map ? v.cast<String, dynamic>() : const <String, dynamic>{};

/// The 11 status codes the API reports.
enum ServerStatus {
  offline(0, 'Offline'),
  online(1, 'Online'),
  starting(2, 'Starting'),
  stopping(3, 'Stopping'),
  restarting(4, 'Restarting'),
  saving(5, 'Saving'),
  loading(6, 'Loading'),
  crashed(7, 'Crashed'),
  pending(8, 'Pending'),
  transferring(9, 'Transferring'),
  preparing(10, 'Preparing');

  const ServerStatus(this.code, this.label);
  final int code;
  final String label;

  static ServerStatus fromCode(int code) =>
      ServerStatus.values.firstWhere((s) => s.code == code, orElse: () => ServerStatus.offline);

  StatusGroup get group => switch (this) {
    ServerStatus.online => StatusGroup.online,
    ServerStatus.offline => StatusGroup.offline,
    ServerStatus.crashed => StatusGroup.crashed,
    _ => StatusGroup.busy,
  };

  /// Whether exaroton is charging credits for the server in this state.
  /// Pending, preparing and transferring happen before the server boots.
  bool get isBilled => switch (this) {
    ServerStatus.online ||
    ServerStatus.starting ||
    ServerStatus.stopping ||
    ServerStatus.restarting ||
    ServerStatus.saving ||
    ServerStatus.loading => true,
    _ => false,
  };
}

/// UI grouping of status codes. See spec "Server status".
enum StatusGroup { online, offline, busy, crashed }

class Account {
  const Account({
    this.id = '',
    required this.name,
    required this.email,
    required this.verified,
    required this.credits,
    this.maxServers,
  });

  final String id;
  final String name;
  final String email;
  final bool verified;
  final double credits;

  /// How many servers the account may own. Null when the API omits it.
  final int? maxServers;

  factory Account.fromJson(Map<String, dynamic> j) => Account(
    id: _toStr(j['id']),
    name: _toStr(j['name']),
    email: _toStr(j['email']),
    verified: j['verified'] == true,
    credits: _toDouble(j['credits']),
    maxServers: j['maxServers'] is num ? _toInt(j['maxServers']) : null,
  );
}

/// One entry of `GET /software/`.
class Software {
  const Software({required this.id, required this.name, required this.version, this.type = '', this.launcher});
  final String id;
  final String name;
  final String version;

  /// Software type, e.g. `vanilla` or `paper`. Empty when the API omits it.
  final String type;

  /// Set for modpacks that need a specific launcher.
  final String? launcher;

  factory Software.fromJson(Map<String, dynamic> j) => Software(
    id: _toStr(j['id']),
    name: _toStr(j['name']),
    version: _toStr(j['version']),
    type: _toStr(j['type']),
    launcher: j['launcher'] is String ? j['launcher'] as String : null,
  );

  /// exaroton runs Bedrock (Nukkit, Bedrock) and Java software. Anything that
  /// is not clearly Bedrock is treated as Java.
  bool get isJava {
    final n = '$name $type'.toLowerCase();
    return !(n.contains('bedrock') || n.contains('nukkit') || n.contains('pocketmine'));
  }

  /// Tick stream needs Java 1.16 or later.
  bool get supportsTick {
    if (!isJava) return false;
    final m = RegExp(r'^1\.(\d+)').firstMatch(version);
    if (m == null) return true; // Unknown scheme (e.g. snapshots): let the stream decide.
    return int.parse(m.group(1)!) >= 16;
  }

  @override
  String toString() => '$name $version';
}

List<String>? _strings(Object? v) => v is List ? v.map((e) => '$e').toList() : null;

/// Software installed on a server: [Software] plus the addon types it
/// supports there.
class ServerSoftware extends Software {
  const ServerSoftware({
    required super.id,
    required super.name,
    required super.version,
    super.type,
    super.launcher,
    this.addons,
  });

  /// Addon types such as `mod` or `plugin`. Null when the API omits it.
  final List<String>? addons;

  factory ServerSoftware.fromJson(Map<String, dynamic> j) {
    final s = Software.fromJson(j);
    return ServerSoftware(
      id: s.id,
      name: s.name,
      version: s.version,
      type: s.type,
      launcher: s.launcher,
      addons: _strings(j['addons']),
    );
  }
}

/// `GET /servers/{id}/software/{softwareId}/`: what installing it would do.
class SoftwareDetails extends ServerSoftware {
  const SoftwareDetails({
    required super.id,
    required super.name,
    required super.version,
    super.type,
    super.launcher,
    super.addons,
    this.description,
    this.link,
    required this.reinstall,
  });

  final String? description;
  final String? link;

  /// Installing deletes every file on the server, and the install call must
  /// confirm it with `reinstall: true`.
  final bool reinstall;

  factory SoftwareDetails.fromJson(Map<String, dynamic> j) {
    final s = ServerSoftware.fromJson(j);
    return SoftwareDetails(
      id: s.id,
      name: s.name,
      version: s.version,
      type: s.type,
      launcher: s.launcher,
      addons: s.addons,
      description: j['description'] is String ? j['description'] as String : null,
      link: j['link'] is String ? j['link'] as String : null,
      reinstall: j['reinstall'] == true,
    );
  }
}

/// Body of `POST /servers/`. Give [software] (an ID) or [softwareType] (the
/// latest version of that type); [software] wins when both are set.
class CreateServerRequest {
  const CreateServerRequest({
    required this.name,
    this.software,
    this.softwareType,
    this.motd,
    this.timezone,
    this.region,
  });

  final String name;
  final String? software;
  final String? softwareType;
  final String? motd;

  /// IANA time zone, e.g. `Europe/Berlin`. The API defaults to UTC.
  final String? timezone;

  /// `eu` or `na`. Null lets the API choose from the time zone.
  final String? region;

  static const regions = ['eu', 'na'];

  /// Empty and blank optional fields are left out.
  Map<String, dynamic> toJson() {
    String? clean(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
    return {
      'name': name.trim(),
      'software': ?clean(software),
      'softwareType': ?clean(softwareType),
      'motd': ?clean(motd),
      'timezone': ?clean(timezone),
      if (regions.contains(region)) 'region': region,
    };
  }
}

class Players {
  const Players({required this.max, required this.count, required this.list});
  final int max;
  final int count;
  final List<String> list;

  factory Players.fromJson(Map<String, dynamic> j) => Players(
    max: _toInt(j['max']),
    count: _toInt(j['count']),
    list: (j['list'] is List) ? (j['list'] as List).whereType<String>().toList() : const [],
  );
}

class Server {
  const Server({
    required this.id,
    required this.name,
    required this.address,
    required this.motd,
    required this.status,
    required this.players,
    this.software,
    this.host,
    this.port,
    this.shared = false,
    this.permissions,
  });

  final String id;
  final String name;
  final String address;
  final String motd;
  final ServerStatus status;
  final Players players;
  final ServerSoftware? software;
  final String? host;
  final int? port;
  final bool shared;

  /// Share Access permission names, e.g. `console`, `players`. Null for the
  /// owner, who may do everything.
  final List<String>? permissions;

  /// Whether this account owns the server (not reached via Share Access).
  bool get isOwner => !shared && permissions == null;

  factory Server.fromJson(Map<String, dynamic> j) {
    final perms = j['permissions'];
    return Server(
      id: _toStr(j['id']),
      name: _toStr(j['name']),
      address: _toStr(j['address']),
      motd: _toStr(j['motd']),
      status: ServerStatus.fromCode(_toInt(j['status'])),
      players: Players.fromJson(_map(j['players'])),
      software: j['software'] is Map ? ServerSoftware.fromJson(_map(j['software'])) : null,
      host: j['host'] is String ? j['host'] as String : null,
      port: j['port'] is num ? _toInt(j['port']) : null,
      shared: j['shared'] == true,
      permissions: perms is List
          ? perms.map((e) => e is String ? e : (e is Map ? _toStr(e['id'] ?? e['name']) : '$e')).toList()
          : (perms is Map ? perms.entries.where((e) => e.value == true).map((e) => '${e.key}').toList() : null),
    );
  }

  Server copyWith({ServerStatus? status, Players? players}) => Server(
    id: id,
    name: name,
    address: address,
    motd: motd,
    status: status ?? this.status,
    players: players ?? this.players,
    software: software,
    host: host,
    port: port,
    shared: shared,
    permissions: permissions,
  );

  /// Whether a feature tab is allowed. Matching is by keyword because the
  /// docs do not list permission names; unknown means allowed.
  bool allows(String feature) {
    final p = permissions;
    if (p == null || !shared) return true;
    final f = feature.toLowerCase();
    return p.any((name) => name.toLowerCase().contains(f));
  }
}

class CreditPool {
  const CreditPool({
    required this.id,
    required this.name,
    required this.credits,
    required this.servers,
    required this.members,
    required this.owner,
    required this.isOwner,
    required this.ownShare,
    required this.ownCredits,
  });

  final String id;
  final String name;
  final double credits;
  final int servers;
  final int members;
  final String owner;
  final bool isOwner;
  final double ownShare;
  final double ownCredits;

  factory CreditPool.fromJson(Map<String, dynamic> j) => CreditPool(
    id: _toStr(j['id']),
    name: _toStr(j['name']),
    credits: _toDouble(j['credits']),
    servers: _toInt(j['servers']),
    members: _toInt(j['members']),
    owner: _toStr(j['owner']),
    isOwner: j['isOwner'] == true,
    ownShare: _toDouble(j['ownShare']),
    ownCredits: _toDouble(j['ownCredits']),
  );
}

class PoolMember {
  const PoolMember({
    required this.account,
    required this.name,
    required this.share,
    required this.credits,
    required this.isOwner,
  });

  final String account;
  final String name;
  final double share;
  final double credits;
  final bool isOwner;

  factory PoolMember.fromJson(Map<String, dynamic> j) => PoolMember(
    account: _toStr(j['account']),
    name: _toStr(j['name']),
    share: _toDouble(j['share']),
    credits: _toDouble(j['credits']),
    isOwner: j['isOwner'] == true,
  );
}

class FileInfo {
  const FileInfo({
    required this.path,
    required this.name,
    required this.isTextFile,
    required this.isConfigFile,
    required this.isDirectory,
    required this.isLog,
    required this.isReadable,
    required this.isWritable,
    required this.size,
    this.children,
  });

  final String path;
  final String name;
  final bool isTextFile;
  final bool isConfigFile;
  final bool isDirectory;
  final bool isLog;
  final bool isReadable;
  final bool isWritable;
  final int size;
  final List<FileInfo>? children;

  factory FileInfo.fromJson(Map<String, dynamic> j) => FileInfo(
    path: _toStr(j['path']),
    name: _toStr(j['name']),
    isTextFile: j['isTextFile'] == true,
    isConfigFile: j['isConfigFile'] == true,
    isDirectory: j['isDirectory'] == true,
    isLog: j['isLog'] == true,
    isReadable: j['isReadable'] == true,
    isWritable: j['isWritable'] == true,
    size: _toInt(j['size']),
    children: j['children'] is List
        ? (j['children'] as List).whereType<Map>().map((e) => FileInfo.fromJson(e.cast())).toList()
        : null,
  );
}

enum ConfigOptionType { string, integer, float, boolean, select, multiselect, unknown }

class ConfigOption {
  const ConfigOption({
    required this.key,
    required this.label,
    required this.type,
    required this.value,
    this.options = const [],
    this.min,
    this.max,
    this.step,
  });

  final String key;
  final String label;
  final ConfigOptionType type;

  /// String, num, bool or `List<String>`, depending on [type].
  final Object? value;
  final List<String> options;
  final num? min;
  final num? max;
  final num? step;

  factory ConfigOption.fromJson(Map<String, dynamic> j) {
    final t = _toStr(j['type']).toLowerCase();
    final type = ConfigOptionType.values.firstWhere((e) => e.name == t, orElse: () => ConfigOptionType.unknown);
    return ConfigOption(
      key: _toStr(j['key']),
      label: _toStr(j['label'], _toStr(j['key'])),
      type: type,
      value: j['value'],
      options: j['options'] is List ? (j['options'] as List).map((e) => '$e').toList() : const [],
      min: j['min'] is num ? j['min'] as num : null,
      max: j['max'] is num ? j['max'] as num : null,
      step: j['step'] is num ? j['step'] as num : null,
    );
  }
}

class SharedLog {
  const SharedLog({required this.id, required this.url, required this.raw});
  final String id;
  final String url;
  final String raw;

  factory SharedLog.fromJson(Map<String, dynamic> j) =>
      SharedLog(id: _toStr(j['id']), url: _toStr(j['url']), raw: _toStr(j['raw']));
}

/// Memory reading from the `stats` stream.
class MemoryStats {
  const MemoryStats({required this.percent, required this.usage});
  final double percent;

  /// Bytes in use.
  final int usage;

  factory MemoryStats.fromJson(Map<String, dynamic> j) {
    final m = _map(j['memory']);
    return MemoryStats(percent: _toDouble(m['percent']), usage: _toInt(m['usage']));
  }
}
