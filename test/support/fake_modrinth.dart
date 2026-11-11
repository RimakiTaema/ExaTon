import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exaton/core/modrinth/modrinth.dart';

/// Routes Modrinth calls by "METHOD /path" (the /v2 prefix dropped) or the
/// full URL for CDN downloads.
class FakeModrinth implements HttpClientAdapter {
  FakeModrinth(this.routes);
  final Map<String, (int, Object?)> routes;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    requests.add(o);
    final key = o.uri.host == 'api.modrinth.com'
        ? '${o.method} ${o.uri.path.replaceFirst('/v2', '')}'
        : '${o.method} ${o.uri}';
    final r = routes[key];
    if (r == null) return ResponseBody.fromString('{"error":"not_found"}', 404);
    final (status, data) = r;
    if (data is Uint8List) return ResponseBody.fromBytes(data, status);
    return ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ModrinthClient fakeModrinth(FakeModrinth a) =>
    ModrinthClient(dio: Dio()..httpClientAdapter = a, userAgent: 'ExaTon/test');
