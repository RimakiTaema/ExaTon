import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../exaroton/models.dart';

const modrinthApiBase = 'https://api.modrinth.com/v2';

class ModrinthException implements Exception {
  ModrinthException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// What a server can take from Modrinth: mods or plugins, for which loaders,
/// and which Minecraft version.
class AddonTarget {
  const AddonTarget({required this.kind, required this.loaders, this.gameVersion});

  final AddonKind kind;

  /// Modrinth loader names that run on this server, best match first. Empty
  /// when the software does not say (a modpack, say); the user then picks one.
  final List<String> loaders;

  /// The Minecraft version, or null when the software version is not one
  /// (modpacks number their own releases).
  final String? gameVersion;

  /// The server folder the files go in.
  String get folder => kind.folder;

  AddonTarget withLoaders(List<String> loaders) => AddonTarget(kind: kind, loaders: loaders, gameVersion: gameVersion);
}

enum AddonKind {
  mod('mods', 'Mods', 'mod', ['fabric', 'forge', 'neoforge', 'quilt']),
  plugin('plugins', 'Plugins', 'plugin', ['paper', 'spigot', 'bukkit', 'purpur', 'folia']),
  proxyPlugin('plugins', 'Plugins', 'plugin', ['velocity', 'bungeecord', 'waterfall']);

  const AddonKind(this.folder, this.label, this.singular, this.choices);
  final String folder;
  final String label;
  final String singular;

  /// Loaders offered when the software does not name one.
  final List<String> choices;
}

final _releaseVersion = RegExp(r'^\d+\.\d+(\.\d+)?$');

/// Loaders each exaroton software type runs, best match first. Paper runs
/// Spigot and Bukkit plugins, Purpur runs Paper ones, Quilt runs Fabric mods.
const _loadersByType = <String, List<String>>{
  'fabric': ['fabric'],
  'quilt': ['quilt', 'fabric'],
  'forge': ['forge'],
  'neoforge': ['neoforge'],
  'paper': ['paper', 'spigot', 'bukkit'],
  'purpur': ['purpur', 'paper', 'spigot', 'bukkit'],
  'folia': ['folia'],
  'spigot': ['spigot', 'bukkit'],
  'bukkit': ['bukkit'],
  'velocity': ['velocity'],
  'waterfall': ['waterfall', 'bungeecord'],
  'bungeecord': ['bungeecord'],
};

const _proxyLoaders = {'velocity', 'waterfall', 'bungeecord'};

/// Works out what [software] can install from Modrinth. Null when it takes
/// neither mods nor plugins (Vanilla, Bedrock).
AddonTarget? addonTargetFor(ServerSoftware? software) {
  if (software == null || !software.isJava) return null;
  final addons = software.addons ?? const [];
  final key = '${software.type} ${software.name}'.toLowerCase();
  var loaders = const <String>[];
  var matched = '';
  for (final e in _loadersByType.entries) {
    // "neoforge" contains "forge": prefer the longer match.
    if (key.contains(e.key) && e.key.length > matched.length) {
      matched = e.key;
      loaders = e.value;
    }
  }
  final AddonKind kind;
  if (loaders.isNotEmpty && _proxyLoaders.contains(loaders.first)) {
    kind = AddonKind.proxyPlugin;
  } else if (addons.contains('mod') || (loaders.isNotEmpty && AddonKind.mod.choices.contains(loaders.first))) {
    kind = AddonKind.mod;
  } else if (addons.contains('plugin') || loaders.isNotEmpty) {
    kind = AddonKind.plugin;
  } else {
    return null;
  }
  // Modpacks number their own releases.
  final pack = software.type == 'modpack' || software.launcher != null;
  final version = !pack && _releaseVersion.hasMatch(software.version) ? software.version : null;
  return AddonTarget(kind: kind, loaders: loaders, gameVersion: version);
}

/// One search result.
class ModrinthProject {
  const ModrinthProject({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    this.iconUrl,
    this.author,
    this.downloads = 0,
  });

  final String id;
  final String slug;
  final String title;
  final String description;
  final String? iconUrl;
  final String? author;
  final int downloads;

  factory ModrinthProject.fromJson(Map<String, dynamic> j) => ModrinthProject(
    id: '${j['project_id'] ?? j['id'] ?? ''}',
    slug: '${j['slug'] ?? ''}',
    title: '${j['title'] ?? ''}',
    description: '${j['description'] ?? ''}',
    iconUrl: j['icon_url'] is String && (j['icon_url'] as String).isNotEmpty ? j['icon_url'] as String : null,
    author: j['author'] is String ? j['author'] as String : null,
    downloads: (j['downloads'] as num?)?.toInt() ?? 0,
  );

  Uri get pageUrl => Uri.parse('https://modrinth.com/project/${slug.isEmpty ? id : slug}');
}

class ModrinthFile {
  const ModrinthFile({required this.url, required this.filename, required this.primary, this.sha1, this.size = 0});
  final String url;
  final String filename;
  final bool primary;
  final String? sha1;
  final int size;

  factory ModrinthFile.fromJson(Map<String, dynamic> j) => ModrinthFile(
    url: '${j['url'] ?? ''}',
    filename: '${j['filename'] ?? ''}',
    primary: j['primary'] == true,
    sha1: j['hashes'] is Map ? (j['hashes'] as Map)['sha1'] as String? : null,
    size: (j['size'] as num?)?.toInt() ?? 0,
  );
}

class ModrinthDependency {
  const ModrinthDependency({this.projectId, this.versionId, required this.type});
  final String? projectId;
  final String? versionId;

  /// `required`, `optional`, `incompatible` or `embedded`.
  final String type;

  factory ModrinthDependency.fromJson(Map<String, dynamic> j) => ModrinthDependency(
    projectId: j['project_id'] as String?,
    versionId: j['version_id'] as String?,
    type: '${j['dependency_type'] ?? ''}',
  );
}

class ModrinthVersion {
  const ModrinthVersion({
    required this.id,
    required this.projectId,
    required this.name,
    required this.versionNumber,
    required this.files,
    this.dependencies = const [],
    this.gameVersions = const [],
    this.loaders = const [],
  });

  final String id;
  final String projectId;
  final String name;
  final String versionNumber;
  final List<ModrinthFile> files;
  final List<ModrinthDependency> dependencies;
  final List<String> gameVersions;
  final List<String> loaders;

  /// The file to install: the one marked primary, else the first.
  ModrinthFile? get primaryFile => files.where((f) => f.primary).firstOrNull ?? files.firstOrNull;

  Iterable<ModrinthDependency> get required => dependencies.where((d) => d.type == 'required');

  factory ModrinthVersion.fromJson(Map<String, dynamic> j) => ModrinthVersion(
    id: '${j['id'] ?? ''}',
    projectId: '${j['project_id'] ?? ''}',
    name: '${j['name'] ?? ''}',
    versionNumber: '${j['version_number'] ?? ''}',
    files: [for (final f in (j['files'] as List? ?? const []).whereType<Map>()) ModrinthFile.fromJson(f.cast())],
    dependencies: [
      for (final d in (j['dependencies'] as List? ?? const []).whereType<Map>()) ModrinthDependency.fromJson(d.cast()),
    ],
    gameVersions: (j['game_versions'] as List? ?? const []).whereType<String>().toList(),
    loaders: (j['loaders'] as List? ?? const []).whereType<String>().toList(),
  );
}

class ModrinthSearchPage {
  const ModrinthSearchPage(this.hits, this.total);
  final List<ModrinthProject> hits;
  final int total;
}

/// Search facets for [target]: its loaders OR-ed, and its game version.
String searchFacets(AddonTarget target, {bool anyVersion = false}) {
  final facets = <List<String>>[
    // Modrinth files plugins under either type.
    ['project_type:mod', 'project_type:plugin'],
    if (target.loaders.isNotEmpty) [for (final l in target.loaders) 'categories:$l'],
    if (!anyVersion && target.gameVersion != null) ['versions:${target.gameVersion}'],
  ];
  return jsonEncode(facets);
}

/// Read-only client for the public Modrinth API. No account or key.
class ModrinthClient {
  ModrinthClient({Dio? dio, String baseUrl = modrinthApiBase, String userAgent = 'ExaTon'}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 60)
      ..validateStatus = (_) => true;
    // Modrinth asks clients to name themselves.
    _dio.options.headers['User-Agent'] = userAgent;
  }

  final Dio _dio;

  Future<ModrinthSearchPage> search(
    AddonTarget target, {
    String query = '',
    bool anyVersion = false,
    int offset = 0,
  }) async {
    final data = await _json(
      () => _dio.get(
        '/search',
        queryParameters: {
          'query': query,
          'facets': searchFacets(target, anyVersion: anyVersion),
          'limit': 20,
          'offset': offset,
          if (query.trim().isEmpty) 'index': 'downloads',
        },
      ),
    );
    final m = data is Map ? data.cast<String, dynamic>() : const <String, dynamic>{};
    return ModrinthSearchPage([
      for (final h in (m['hits'] as List? ?? const []).whereType<Map>()) ModrinthProject.fromJson(h.cast()),
    ], (m['total_hits'] as num?)?.toInt() ?? 0);
  }

  /// Versions of [project] for [loaders] and [gameVersion], newest first.
  Future<List<ModrinthVersion>> versions(String project, {List<String> loaders = const [], String? gameVersion}) async {
    final data = await _json(
      () => _dio.get(
        '/project/$project/version',
        queryParameters: {
          if (loaders.isNotEmpty) 'loaders': jsonEncode(loaders),
          if (gameVersion != null) 'game_versions': jsonEncode([gameVersion]),
        },
      ),
    );
    return [for (final v in (data is List ? data : const []).whereType<Map>()) ModrinthVersion.fromJson(v.cast())];
  }

  Future<ModrinthVersion> version(String id) async {
    final data = await _json(() => _dio.get('/version/$id'));
    if (data is! Map) throw ModrinthException('Modrinth sent an unexpected answer');
    return ModrinthVersion.fromJson(data.cast());
  }

  Future<List<ModrinthProject>> projects(Iterable<String> ids) async {
    final list = ids.toSet().toList();
    if (list.isEmpty) return const [];
    final data = await _json(() => _dio.get('/projects', queryParameters: {'ids': jsonEncode(list)}));
    return [for (final p in (data is List ? data : const []).whereType<Map>()) ModrinthProject.fromJson(p.cast())];
  }

  /// The newest version for each installed file, keyed by its SHA-1.
  Future<Map<String, ModrinthVersion>> updates(
    Iterable<String> sha1s, {
    List<String> loaders = const [],
    String? gameVersion,
  }) async {
    final hashes = sha1s.toSet().toList();
    if (hashes.isEmpty) return const {};
    final data = await _json(
      () => _dio.post(
        '/version_files/update',
        data: {
          'hashes': hashes,
          'algorithm': 'sha1',
          if (loaders.isNotEmpty) 'loaders': loaders,
          if (gameVersion != null) 'game_versions': [gameVersion],
        },
      ),
    );
    if (data is! Map) return const {};
    return {
      for (final e in data.entries)
        if (e.value is Map) '${e.key}': ModrinthVersion.fromJson((e.value as Map).cast()),
    };
  }

  /// Downloads a file from Modrinth's CDN.
  Future<Uint8List> download(ModrinthFile file) async {
    final uri = Uri.tryParse(file.url);
    // Only Modrinth's own CDN: the URL came from the API, but check anyway.
    if (uri == null ||
        !uri.isScheme('https') ||
        !(uri.host == 'cdn.modrinth.com' || uri.host.endsWith('.modrinth.com'))) {
      throw ModrinthException('Refusing to download from ${uri?.host ?? 'an unknown host'}');
    }
    final Response<List<int>> res;
    try {
      res = await _dio.get<List<int>>(file.url, options: Options(responseType: ResponseType.bytes));
    } on DioException catch (e) {
      throw ModrinthException(_transport(e));
    }
    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300) throw ModrinthException('Download failed ($code)', statusCode: code);
    return Uint8List.fromList(res.data ?? const []);
  }

  Future<Object?> _json(Future<Response<dynamic>> Function() call) async {
    final Response<dynamic> res;
    try {
      res = await call();
    } on DioException catch (e) {
      throw ModrinthException(_transport(e));
    }
    final code = res.statusCode ?? 0;
    if (code == 404) throw ModrinthException('Not found on Modrinth', statusCode: 404);
    if (code == 429) {
      throw ModrinthException('Modrinth is rate limiting requests. Try again in a minute.', statusCode: 429);
    }
    if (code < 200 || code >= 300) throw ModrinthException('Modrinth error ($code)', statusCode: code);
    final d = res.data;
    if (d is String) {
      try {
        return jsonDecode(d);
      } catch (_) {
        throw ModrinthException('Modrinth sent an unexpected answer');
      }
    }
    return d;
  }

  static String _transport(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => 'Modrinth did not answer in time',
    _ => 'Could not reach Modrinth',
  };

  void close() => _dio.close();
}
