import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

enum ProbeOutcome { passed, failed, timeout }

/// What one request to the API showed.
class ProbeResult {
  const ProbeResult({required this.outcome, required this.latency, required this.detail, this.statusCode});

  final ProbeOutcome outcome;
  final Duration latency;

  /// HTTP status, when the API answered at all.
  final int? statusCode;

  /// The API's error text, the transport error, or "OK".
  final String detail;

  bool get passed => outcome == ProbeOutcome.passed;

  /// One line for the status row, e.g. "Passed - HTTP 200 in 84 ms".
  String get summary {
    final ms = '${latency.inMilliseconds} ms';
    return switch (outcome) {
      ProbeOutcome.passed => 'Passed - HTTP $statusCode in $ms',
      ProbeOutcome.timeout => 'Timed out after $ms',
      ProbeOutcome.failed => statusCode == null ? 'Failed - $detail' : 'Failed - HTTP $statusCode in $ms - $detail',
    };
  }
}

/// Whether an anonymous request reached the API: any answer that is not a
/// server error counts, including 401 and 404.
bool reachedApi(int status, Object? body) => status > 0 && status < 500;

/// Whether an authenticated request worked: 2xx with `success: true`.
bool envelopeOk(int status, Object? body) => status >= 200 && status < 300 && body is Map && body['success'] == true;

/// Runs [call] and reports how it went. Never throws: transport errors and
/// timeouts become results. [passes] decides from the status and the decoded
/// body; [now] is replaceable for tests.
Future<ProbeResult> runProbe(
  Future<Response<dynamic>> Function() call, {
  required bool Function(int status, Object? body) passes,
  Duration timeout = const Duration(seconds: 10),
  DateTime Function() now = DateTime.now,
}) async {
  final start = now();
  Duration taken() => now().difference(start);
  try {
    final res = await call().timeout(timeout);
    final status = res.statusCode ?? 0;
    Object? body = res.data;
    if (body is String && body.isNotEmpty) {
      try {
        body = jsonDecode(body);
      } catch (_) {}
    }
    final ok = passes(status, body);
    final apiError = body is Map && body['error'] is String ? body['error'] as String : null;
    return ProbeResult(
      outcome: ok ? ProbeOutcome.passed : ProbeOutcome.failed,
      latency: taken(),
      statusCode: status,
      detail: ok ? 'OK' : (apiError ?? 'Unexpected response'),
    );
  } on TimeoutException {
    return ProbeResult(outcome: ProbeOutcome.timeout, latency: taken(), detail: 'No answer in time');
  } on DioException catch (e) {
    final timedOut =
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
    return ProbeResult(
      outcome: timedOut ? ProbeOutcome.timeout : ProbeOutcome.failed,
      latency: taken(),
      statusCode: e.response?.statusCode,
      detail: timedOut ? 'No answer in time' : (e.message ?? 'Could not reach exaroton'),
    );
  } catch (e) {
    return ProbeResult(outcome: ProbeOutcome.failed, latency: taken(), detail: '$e');
  }
}
