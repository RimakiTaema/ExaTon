import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_info.dart';
import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../core/modrinth/modrinth.dart';
import '../../core/storage/database.dart';
import '../accounts/accounts.dart';
import '../settings/settings.dart';

/// Overridable in tests.
final modrinthClientProvider = Provider<ModrinthClient>((ref) {
  final c = ModrinthClient(userAgent: 'ExaTon/$appVersionName');
  ref.onDispose(c.close);
  return c;
});

/// A file ExaTon installed from Modrinth, remembered so updates can be found.
class InstalledAddon {
  const InstalledAddon({
    required this.path,
    required this.projectId,
    required this.versionId,
    required this.title,
    required this.versionNumber,
    this.sha1,
    this.iconUrl,
  });

  final String path;
  final String projectId;
  final String versionId;
  final String title;
  final String versionNumber;
  final String? sha1;
  final String? iconUrl;

  String get filename => path.split('/').last;

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'versionId': versionId,
    'title': title,
    'versionNumber': versionNumber,
    'sha1': ?sha1,
    'iconUrl': ?iconUrl,
  };

  factory InstalledAddon.fromJson(String path, Map<String, dynamic> j) => InstalledAddon(
    path: path,
    projectId: '${j['projectId'] ?? ''}',
    versionId: '${j['versionId'] ?? ''}',
    title: '${j['title'] ?? ''}',
    versionNumber: '${j['versionNumber'] ?? ''}',
    sha1: j['sha1'] as String?,
    iconUrl: j['iconUrl'] as String?,
  );
}

/// Installs from Modrinth into a server's mods or plugins folder, and keeps
/// a local record of what it installed.
class AddonInstaller {
  AddonInstaller({required this.exaroton, required this.modrinth, required this.db, required this.serverId});

  final ExarotonClient exaroton;
  final ModrinthClient modrinth;
  final AppDatabase db;
  final String serverId;

  String get _key => 'addons.$serverId';

  Future<Map<String, InstalledAddon>> installed() async {
    final j = await db.readJson(_key) ?? const {};
    return {
      for (final e in j.entries)
        if (e.value is Map) e.key: InstalledAddon.fromJson(e.key, (e.value as Map).cast()),
    };
  }

  Future<void> _save(Map<String, InstalledAddon> all) =>
      db.writeJson(_key, {for (final e in all.entries) e.key: e.value.toJson()});

  /// The newest version of [projectId] that runs on [target].
  Future<ModrinthVersion?> bestVersion(String projectId, AddonTarget target) async {
    final list = await modrinth.versions(projectId, loaders: target.loaders, gameVersion: target.gameVersion);
    return list.where((v) => v.primaryFile != null).firstOrNull;
  }

  /// [version] plus its required dependencies that are not installed yet,
  /// dependencies first. Stops after a few levels to avoid cycles.
  Future<List<ModrinthVersion>> plan(ModrinthVersion version, AddonTarget target) async {
    final have = (await installed()).values.map((a) => a.projectId).toSet();
    final out = <ModrinthVersion>[];
    final seen = <String>{version.projectId};
    Future<void> walk(ModrinthVersion v, int depth) async {
      if (depth < 4) {
        for (final d in v.required) {
          final pid = d.projectId;
          if (pid != null && (seen.contains(pid) || have.contains(pid))) continue;
          ModrinthVersion? dep;
          if (d.versionId != null) {
            dep = await modrinth.version(d.versionId!);
          } else if (pid != null) {
            dep = await bestVersion(pid, target);
          }
          if (dep == null || seen.contains(dep.projectId) || have.contains(dep.projectId)) continue;
          seen.add(dep.projectId);
          await walk(dep, depth + 1);
        }
      }
      out.add(v);
    }

    await walk(version, 0);
    return out;
  }

  /// Downloads each version's file and writes it to [target]'s folder.
  /// [titles] names projects for the record; [onStep] reports progress.
  Future<void> install(
    List<ModrinthVersion> versions,
    AddonTarget target, {
    Map<String, ModrinthProject> projects = const {},
    void Function(int done, int total, String name)? onStep,
  }) async {
    final all = await installed();
    for (var i = 0; i < versions.length; i++) {
      final v = versions[i];
      final file = v.primaryFile;
      if (file == null) continue;
      onStep?.call(i, versions.length, file.filename);
      final bytes = await modrinth.download(file);
      final path = '${target.folder}/${file.filename}';
      await exaroton.writeFile(serverId, path, bytes);
      final p = projects[v.projectId];
      all[path] = InstalledAddon(
        path: path,
        projectId: v.projectId,
        versionId: v.id,
        title: p?.title ?? v.name,
        versionNumber: v.versionNumber,
        sha1: file.sha1,
        iconUrl: p?.iconUrl,
      );
      await _save(all);
    }
    onStep?.call(versions.length, versions.length, '');
  }

  /// Newer versions for installed files, keyed by path.
  Future<Map<String, ModrinthVersion>> findUpdates(AddonTarget target) async {
    final all = await installed();
    final byHash = {
      for (final a in all.values)
        if (a.sha1 != null) a.sha1!: a,
    };
    final latest = await modrinth.updates(byHash.keys, loaders: target.loaders, gameVersion: target.gameVersion);
    return {
      for (final e in latest.entries)
        if (byHash[e.key] != null && e.value.id != byHash[e.key]!.versionId) byHash[e.key]!.path: e.value,
    };
  }

  /// Replaces the file at [path] with [version].
  Future<void> update(String path, ModrinthVersion version, AddonTarget target) async {
    final all = await installed();
    final old = all[path];
    final file = version.primaryFile;
    if (file == null) return;
    final bytes = await modrinth.download(file);
    final newPath = '${target.folder}/${file.filename}';
    await exaroton.writeFile(serverId, newPath, bytes);
    if (newPath != path) await _deleteQuietly(path);
    all.remove(path);
    all[newPath] = InstalledAddon(
      path: newPath,
      projectId: version.projectId,
      versionId: version.id,
      title: old?.title ?? version.name,
      versionNumber: version.versionNumber,
      sha1: file.sha1,
      iconUrl: old?.iconUrl,
    );
    await _save(all);
  }

  Future<void> remove(String path) async {
    await exaroton.deleteFile(serverId, path);
    final all = await installed();
    if (all.remove(path) != null) await _save(all);
  }

  /// Drops records whose file is gone (deleted in the Files tab, say).
  Future<void> forgetMissing(Set<String> present) async {
    final all = await installed();
    final before = all.length;
    all.removeWhere((path, _) => !present.contains(path));
    if (all.length != before) await _save(all);
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await exaroton.deleteFile(serverId, path);
    } on ExarotonException {
      // Already gone.
    }
  }
}

final addonInstallerProvider = Provider.autoDispose.family<AddonInstaller?, String>((ref, serverId) {
  final client = ref.watch(clientProvider);
  if (client == null) return null;
  return AddonInstaller(
    exaroton: client,
    modrinth: ref.watch(modrinthClientProvider),
    db: ref.watch(databaseProvider),
    serverId: serverId,
  );
});

/// What [server] can install, or null.
AddonTarget? addonTargetOf(Server server) => addonTargetFor(server.software);
