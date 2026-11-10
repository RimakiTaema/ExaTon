import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'models.dart';

const exarotonApiBase = 'https://api.exaroton.com/v1';

/// An error from the API envelope or the transport.
class ExarotonException implements Exception {
  ExarotonException(this.message, {this.statusCode, this.fromApi = false});
  final String message;
  final int? statusCode;

  /// Whether [message] is the API's own error text, not a fallback.
  final bool fromApi;

  bool get isForbidden => statusCode == 403;
  bool get isTooLarge => statusCode == 413;
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => statusCode == null ? message : '$message ($statusCode)';
}

/// `POST /servers/` answered 413: the account owns as many servers as it may.
class ServerLimitReachedException extends ExarotonException {
  ServerLimitReachedException([String? apiError])
    : super(apiError ?? 'Server limit reached', statusCode: 413, fromApi: apiError != null);
}

/// Result of start, stop and restart.
enum ActionResult {
  /// The request was accepted.
  accepted,

  /// HTTP 208: the server is already starting or stopping.
  alreadyInProgress,
}

/// Pure Dart client for api.exaroton.com. No Flutter imports, so it can be
/// tested on its own with recorded responses.
class ExarotonClient {
  ExarotonClient(String token, {Dio? dio, String baseUrl = exarotonApiBase}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      // Decode JSON in [_unwrap], so a non-JSON error page (a proxy's 413,
      // say) keeps its status code instead of failing in the transformer.
      ..responseType = ResponseType.plain
      // Handle every status in [_unwrap] so 208, 403 and 413 keep their body.
      ..validateStatus = (_) => true;
    _dio.interceptors.add(_AuthInterceptor(token));
  }

  final Dio _dio;

  Dio get dio => _dio;

  // ── Account ───────────────────────────────────────────────────────────

  Future<Account> getAccount() async => Account.fromJson(_asMap(await _get('/account/')));

  // ── Servers ───────────────────────────────────────────────────────────

  Future<List<Server>> getServers() async => _asList(await _get('/servers/')).map((e) => Server.fromJson(e)).toList();

  Future<Server> getServer(String id) async => Server.fromJson(_asMap(await _get('/servers/$id/')));

  /// Creates a server owned by this account. Throws
  /// [ServerLimitReachedException] on 413.
  Future<Server> createServer(CreateServerRequest request) async {
    try {
      return Server.fromJson(_asMap(await _send(() => _dio.post('/servers/', data: request.toJson()))));
    } on ExarotonException catch (e) {
      if (e.statusCode == 413) throw ServerLimitReachedException(e.fromApi ? e.message : null);
      rethrow;
    }
  }

  /// Permanently deletes a server and all its files. Owner only, and only
  /// while the server is offline or crashed; otherwise the API answers 400
  /// or 403 with the reason.
  Future<void> deleteServer(String id) async {
    await _send(() => _dio.delete('/servers/$id/'));
  }

  /// Starts a server. Set [useOwnCredits] on a server shared with you to pay
  /// with your own credits instead of the owner's.
  Future<ActionResult> start(String id, {bool useOwnCredits = false}) => useOwnCredits
      ? _action(() => _dio.post('/servers/$id/start/', data: {'useOwnCredits': true}))
      : _action(() => _dio.get('/servers/$id/start/'));

  Future<ActionResult> stop(String id) => _action(() => _dio.get('/servers/$id/stop/'));

  Future<ActionResult> restart(String id) => _action(() => _dio.get('/servers/$id/restart/'));

  Future<void> extendStopTime(String id, int seconds) async {
    await _send(() => _dio.post('/servers/$id/extend-time/', data: {'time': seconds}));
  }

  Future<void> sendCommand(String id, String command) async {
    await _send(() => _dio.post('/servers/$id/command/', data: {'command': command}));
  }

  Future<String> getLog(String id) async => (_asMap(await _get('/servers/$id/logs/'))['content'] as String?) ?? '';

  Future<SharedLog> shareLog(String id) async => SharedLog.fromJson(_asMap(await _get('/servers/$id/logs/share/')));

  Future<int> getRam(String id) async => (_asMap(await _get('/servers/$id/options/ram/'))['ram'] as num).toInt();

  /// RAM in GB, 2 to 16.
  Future<int> setRam(String id, int gb) async {
    if (gb < 2 || gb > 16) throw ArgumentError.value(gb, 'gb', 'RAM must be 2 to 16 GB');
    final data = await _send(() => _dio.post('/servers/$id/options/ram/', data: {'ram': gb}));
    return (data is Map && data['ram'] is num) ? (data['ram'] as num).toInt() : gb;
  }

  Future<String> getMotd(String id) async =>
      (_asMap(await _get('/servers/$id/options/motd/'))['motd'] as String?) ?? '';

  Future<void> setMotd(String id, String motd) async {
    await _send(() => _dio.post('/servers/$id/options/motd/', data: {'motd': motd}));
  }

  // ── Software ──────────────────────────────────────────────────────────

  /// Software that can be installed. [type] narrows to one software type,
  /// [launcher] to modpacks of one launcher.
  Future<List<Software>> listSoftware({String? type, String? launcher}) async =>
      _asList(await _send(() => _dio.get('/software/', queryParameters: {'type': ?type, 'launcher': ?launcher})))
          .map(Software.fromJson)
          .toList();

  /// What installing [softwareId] on the server would do, including whether
  /// it needs a reinstall.
  Future<SoftwareDetails> getServerSoftware(String id, String softwareId) async =>
      SoftwareDetails.fromJson(_asMap(await _get('/servers/$id/software/$softwareId/')));

  /// Installs software. [reinstall] must be true when
  /// [SoftwareDetails.reinstall] is; that deletes every file on the server.
  Future<void> installSoftware(String id, String softwareId, {bool reinstall = false}) async {
    await _send(
      () =>
          _dio.post('/servers/$id/software/$softwareId/', data: reinstall ? {'reinstall': true} : <String, dynamic>{}),
    );
  }

  // ── Player lists ──────────────────────────────────────────────────────

  Future<List<String>> getPlayerLists(String id) async =>
      (await _getList('/servers/$id/playerlists/')).map((e) => '$e').toList();

  Future<List<String>> getPlayerList(String id, String list) async =>
      (await _getList('/servers/$id/playerlists/$list/')).map((e) => '$e').toList();

  /// Adds every entry in one call. Each call is a storage operation, so
  /// callers should batch changes.
  Future<List<String>> addToPlayerList(String id, String list, List<String> entries) async =>
      _strings(await _send(() => _dio.put('/servers/$id/playerlists/$list/', data: {'entries': entries})));

  Future<List<String>> removeFromPlayerList(String id, String list, List<String> entries) async =>
      _strings(await _send(() => _dio.delete('/servers/$id/playerlists/$list/', data: {'entries': entries})));

  // ── Files ─────────────────────────────────────────────────────────────

  Future<FileInfo> getFileInfo(String id, String path) async =>
      FileInfo.fromJson(_asMap(await _get('/servers/$id/files/info/${_path(path)}')));

  Future<Uint8List> readFile(String id, String path) async {
    final res = await _dio.get<List<int>>(
      '/servers/$id/files/data/${_path(path)}',
      options: Options(responseType: ResponseType.bytes),
    );
    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw _errorFromBytes(res.data, code);
    }
    return Uint8List.fromList(res.data ?? const []);
  }

  Future<String> readTextFile(String id, String path) async =>
      utf8.decode(await readFile(id, path), allowMalformed: true);

  Future<void> writeFile(String id, String path, List<int> bytes) async {
    await _send(
      () => _dio.put(
        '/servers/$id/files/data/${_path(path)}',
        data: Stream.fromIterable([bytes]),
        options: Options(contentType: 'application/octet-stream', headers: {Headers.contentLengthHeader: bytes.length}),
      ),
    );
  }

  Future<void> writeTextFile(String id, String path, String text) => writeFile(id, path, utf8.encode(text));

  Future<void> createDirectory(String id, String path) async {
    await _send(
      () => _dio.put('/servers/$id/files/data/${_path(path)}', options: Options(contentType: 'inode/directory')),
    );
  }

  Future<void> deleteFile(String id, String path) async {
    await _send(() => _dio.delete('/servers/$id/files/data/${_path(path)}'));
  }

  // ── Config files ──────────────────────────────────────────────────────

  Future<List<ConfigOption>> getConfig(String id, String path) async =>
      (await _getList('/servers/$id/files/config/${_path(path)}'))
          .whereType<Map>()
          .map((e) => ConfigOption.fromJson(e.cast()))
          .toList();

  /// Sends only the changed keys.
  Future<List<ConfigOption>> updateConfig(String id, String path, Map<String, Object?> values) async {
    final data = await _send(() => _dio.post('/servers/$id/files/config/${_path(path)}', data: values));
    return data is List ? data.whereType<Map>().map((e) => ConfigOption.fromJson(e.cast())).toList() : const [];
  }

  // ── Credit pools (read only) ──────────────────────────────────────────

  Future<List<CreditPool>> getPools() async => _asList(await _get('/billing/pools/')).map(CreditPool.fromJson).toList();

  Future<CreditPool> getPool(String poolId) async => CreditPool.fromJson(_asMap(await _get('/billing/pools/$poolId/')));

  Future<List<Server>> getPoolServers(String poolId) async =>
      _asList(await _get('/billing/pools/$poolId/servers/')).map(Server.fromJson).toList();

  /// Throws [ExarotonException] with 403 without the "View members" permission.
  Future<List<PoolMember>> getPoolMembers(String poolId) async =>
      _asList(await _get('/billing/pools/$poolId/members/')).map(PoolMember.fromJson).toList();

  void close() => _dio.close();

  // ── Internals ─────────────────────────────────────────────────────────

  /// Encodes each segment and adds the trailing slash; the root is empty.
  static String _path(String path) {
    final p = path.split('/').where((s) => s.isNotEmpty).map(Uri.encodeComponent).join('/');
    return p.isEmpty ? '' : '$p/';
  }

  Future<Object?> _get(String path) => _send(() => _dio.get(path));

  Future<List<Object?>> _getList(String path) async {
    final d = await _get(path);
    return d is List ? d : const [];
  }

  Future<Object?> _send(Future<Response<dynamic>> Function() call) async {
    final Response<dynamic> res;
    try {
      res = await call();
    } on DioException catch (e) {
      throw ExarotonException(_transportMessage(e), statusCode: e.response?.statusCode);
    }
    return _unwrap(res);
  }

  Future<ActionResult> _action(Future<Response<dynamic>> Function() call) async {
    try {
      final res = await call();
      if (res.statusCode == 208) return ActionResult.alreadyInProgress;
      _unwrap(res);
      return ActionResult.accepted;
    } on DioException catch (e) {
      throw ExarotonException(_transportMessage(e), statusCode: e.response?.statusCode);
    }
  }

  /// Unwraps the `{success, error, data}` envelope.
  static Object? _unwrap(Response<dynamic> res) {
    final code = res.statusCode ?? 0;
    var body = res.data;
    if (body is String && body.isNotEmpty) {
      try {
        body = jsonDecode(body);
      } catch (_) {}
    }
    if (body is Map) {
      final ok = body['success'] == true;
      if (ok && code >= 200 && code < 300) return body['data'];
      final apiError = body['error'] is String ? body['error'] as String : null;
      throw ExarotonException(
        _messageFor(code, apiError),
        statusCode: code,
        fromApi: apiError != null && apiError.isNotEmpty,
      );
    }
    if (code >= 200 && code < 300) return body;
    throw ExarotonException(_messageFor(code, null), statusCode: code);
  }

  static ExarotonException _errorFromBytes(List<int>? bytes, int code) {
    String? msg;
    try {
      final j = jsonDecode(utf8.decode(bytes ?? const []));
      if (j is Map) msg = j['error'] as String?;
    } catch (_) {}
    return ExarotonException(_messageFor(code, msg), statusCode: code);
  }

  static String _messageFor(int code, String? apiError) {
    if (apiError != null && apiError.isNotEmpty) return apiError;
    return switch (code) {
      401 => 'Invalid API token',
      403 => 'You do not have permission for this',
      404 => 'Not found',
      413 => 'File is too large',
      >= 500 => 'exaroton had a server error',
      _ => 'Request failed',
    };
  }

  static String _transportMessage(DioException e) => switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => 'Timed out reaching exaroton',
    DioExceptionType.connectionError => 'Could not reach exaroton',
    _ => e.message ?? 'Request failed',
  };

  static Map<String, dynamic> _asMap(Object? d) => d is Map ? d.cast<String, dynamic>() : <String, dynamic>{};

  static List<Map<String, dynamic>> _asList(Object? d) =>
      d is List ? d.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList() : const [];

  static List<String> _strings(Object? d) => d is List ? d.map((e) => '$e').toList() : const [];
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._token);
  final String _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $_token';
    handler.next(options);
  }
}
