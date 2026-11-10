import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exaton/core/exaroton/client.dart';

/// Replays API responses from test/fixtures/*.json (written by hand in the
/// shape of openapi.yaml, not captured from a live account), keyed by
/// "METHOD /path". Records every request for assertions.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.routes);

  /// "GET /account/" → (status, body).
  final Map<String, (int, Object?)> routes;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) await requestStream.drain<void>();
    final key = '${options.method} ${options.uri.path.replaceFirst('/v1', '')}';
    final route = routes[key];
    if (route == null) {
      return ResponseBody.fromString(
        jsonEncode({'success': false, 'error': 'No fixture for $key', 'data': null}),
        404,
        headers: _json,
      );
    }
    final (status, body) = route;
    // Raw bytes, for file downloads such as a server icon.
    if (body is Uint8List) {
      return ResponseBody.fromBytes(
        body,
        status,
        headers: {
          Headers.contentTypeHeader: ['application/octet-stream'],
        },
      );
    }
    return ResponseBody.fromString(body is String ? body : jsonEncode(body), status, headers: _json);
  }

  static const _json = {
    Headers.contentTypeHeader: ['application/json'],
  };

  @override
  void close({bool force = false}) {}
}

/// Loads a fixture response body.
Object? fixture(String name) => jsonDecode(File('test/fixtures/$name.json').readAsStringSync());

Map<String, Object?> ok(Object? data) => {'success': true, 'error': null, 'data': data};
Map<String, Object?> apiError(String error) => {'success': false, 'error': error, 'data': null};

ExarotonClient fakeClient(FakeAdapter adapter, [String token = 'test-token']) {
  final dio = Dio()..httpClientAdapter = adapter;
  return ExarotonClient(token, dio: dio, baseUrl: 'https://api.exaroton.com/v1');
}

/// Routes that make a full account: 3 servers, 1 pool.
Map<String, (int, Object?)> standardRoutes() => {
  'GET /account/': (200, fixture('account')),
  'GET /servers/': (200, fixture('servers')),
  'GET /billing/pools/': (200, fixture('pools')),
  'GET /billing/pools/Pool000000000001/servers/': (200, ok([(fixture('servers') as Map)['data'][0]])),
  'GET /billing/pools/Pool000000000001/members/': (200, fixture('pool_members')),
  'GET /servers/Srv0000000000001/options/ram/': (200, ok({'ram': 4})),
  'GET /servers/Srv0000000000002/options/ram/': (200, ok({'ram': 2})),
  'GET /servers/Srv0000000000003/options/ram/': (200, ok({'ram': 6})),
};
