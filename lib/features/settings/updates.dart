import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_info.dart';

/// Where releases are published. ExaTon is installed from here on every
/// platform, so nothing else tells users about a new version.
const releasesApi = 'https://api.github.com/repos/RimakiTaema/ExaTon/releases/latest';

/// The newest published (non pre-release) version.
@immutable
class ReleaseInfo {
  const ReleaseInfo({required this.version, required this.tag, required this.url});
  final String version;
  final String tag;

  /// The release page, with the downloads and install steps.
  final Uri url;
}

/// "v1.7.2", "1.7.2-beta.1" -> [1, 7, 2]. Null when there is no x.y.z.
List<int>? parseVersion(String tag) {
  final m = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)').firstMatch(tag.trim());
  if (m == null) return null;
  return [for (var i = 1; i <= 3; i++) int.parse(m.group(i)!)];
}

/// Whether [latest] is a higher x.y.z than [current].
bool isNewerVersion(String latest, String current) {
  final a = parseVersion(latest), b = parseVersion(current);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] > b[i];
  }
  return false;
}

/// Reads GitHub's latest-release JSON. Null for a draft or pre-release, or
/// when the tag has no version.
ReleaseInfo? releaseFromJson(Map<String, dynamic> json) {
  if (json['draft'] == true || json['prerelease'] == true) return null;
  final tag = json['tag_name'];
  final url = json['html_url'];
  if (tag is! String || url is! String || parseVersion(tag) == null) return null;
  return ReleaseInfo(version: parseVersion(tag)!.join('.'), tag: tag, url: Uri.parse(url));
}

/// Fetches the latest release JSON. Overridable in tests; returns null under
/// `flutter test` so no test reaches the network.
final latestReleaseFetcherProvider = Provider<Future<Map<String, dynamic>?> Function()>((ref) {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return () async => null;
  return () async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/vnd.github+json', 'User-Agent': 'ExaTon/$appVersionName'},
      ),
    );
    final r = await dio.get<Map<String, dynamic>>(releasesApi);
    return r.data;
  };
});

/// The newer release, or null when this build is up to date. Checked once
/// per launch; invalidate to check again.
final updateCheckProvider = FutureProvider<ReleaseInfo?>((ref) async {
  final json = await ref.watch(latestReleaseFetcherProvider)();
  final latest = json == null ? null : releaseFromJson(json);
  if (latest == null || !isNewerVersion(latest.version, appVersionName)) return null;
  return latest;
});

Future<void> openRelease(ReleaseInfo r) => launchUrl(r.url, mode: LaunchMode.externalApplication);

/// The launch notice: once per run, when a newer release exists.
void showUpdateNotice(BuildContext context, ReleaseInfo r) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(
      content: Text('ExaTon ${r.version} is available'),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(label: 'Download', onPressed: () => openRelease(r)),
    ),
  );
}
