import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';

/// Thrown when the user cancels a running backup or restore.
class BackupCancelled implements Exception {}

/// Progress of a backup or restore.
class BackupProgress {
  const BackupProgress({required this.files, required this.totalFiles, required this.bytes, this.current = ''});
  final int files;

  /// 0 while the file list is still being read.
  final int totalFiles;
  final int bytes;
  final String current;

  double? get fraction => totalFiles == 0 ? null : files / totalFiles;
}

/// The world folder named by `level-name` in server.properties, or "world".
String levelName(String? properties) {
  if (properties != null) {
    for (final line in properties.split('\n')) {
      final l = line.trim();
      if (l.startsWith('level-name=')) {
        final v = l.substring('level-name='.length).trim();
        if (v.isNotEmpty) return v;
      }
    }
  }
  return 'world';
}

/// Root folders worth preselecting: the world and its Bukkit-style
/// dimension folders (`world_nether`, `world_the_end`).
Set<String> defaultWorldFolders(Iterable<String> rootFolders, String level) => {
  for (final f in rootFolders)
    if (f == level || f.startsWith('${level}_')) f,
};

/// A zip entry path that is safe to write: relative, no "..", forward slashes.
String? safeEntryPath(String name) {
  final n = name.replaceAll('\\', '/');
  if (n.startsWith('/') || RegExp(r'^[A-Za-z]:').hasMatch(n)) return null;
  final parts = n.split('/').where((s) => s.isNotEmpty && s != '.').toList();
  if (parts.isEmpty || parts.contains('..')) return null;
  return parts.join('/');
}

/// Downloads server folders into a zip, and uploads a zip back.
class BackupEngine {
  BackupEngine(this.client, this.serverId);
  final ExarotonClient client;
  final String serverId;

  bool _cancelled = false;
  void cancel() => _cancelled = true;
  void _check() {
    if (_cancelled) throw BackupCancelled();
  }

  /// Every file under [folders], as server paths without a leading slash.
  Future<List<FileInfo>> listFiles(List<String> folders) async {
    final out = <FileInfo>[];
    Future<void> walk(String path) async {
      _check();
      final info = await client.getFileInfo(serverId, path);
      for (final c in info.children ?? const <FileInfo>[]) {
        final child = '$path/${c.name}';
        if (c.isDirectory) {
          await walk(child);
        } else {
          out.add(
            FileInfo(
              path: child,
              name: c.name,
              isTextFile: c.isTextFile,
              isConfigFile: c.isConfigFile,
              isDirectory: false,
              isLog: c.isLog,
              isReadable: c.isReadable,
              isWritable: c.isWritable,
              size: c.size,
            ),
          );
        }
      }
    }

    for (final f in folders) {
      await walk(f);
    }
    return out;
  }

  /// Writes [folders] into a zip at [zipPath].
  Future<void> backup(List<String> folders, String zipPath, void Function(BackupProgress) onProgress) async {
    onProgress(const BackupProgress(files: 0, totalFiles: 0, bytes: 0, current: 'Listing files'));
    final files = await listFiles(folders);
    final zip = ZipFileEncoder()..create(zipPath);
    var bytes = 0;
    try {
      for (var i = 0; i < files.length; i++) {
        _check();
        final f = files[i];
        onProgress(BackupProgress(files: i, totalFiles: files.length, bytes: bytes, current: f.path));
        _check();
        // session.lock is held open by a running server and is not needed.
        if (f.name == 'session.lock' || !f.isReadable) continue;
        final data = await client.readFile(serverId, f.path);
        bytes += data.length;
        zip.addArchiveFile(ArchiveFile.bytes(f.path, data));
      }
      onProgress(BackupProgress(files: files.length, totalFiles: files.length, bytes: bytes));
    } finally {
      await zip.close();
      if (_cancelled) {
        try {
          await File(zipPath).delete();
        } catch (_) {}
      }
    }
  }

  /// The top-level folders a zip would write to.
  static Set<String> topFolders(String zipPath) {
    final input = InputFileStream(zipPath);
    try {
      final archive = ZipDecoder().decodeStream(input);
      return {
        for (final e in archive)
          if (safeEntryPath(e.name) case final path? when path.contains('/')) path.split('/').first,
      };
    } finally {
      input.closeSync();
    }
  }

  /// Uploads the zip at [zipPath]. With [replace], the top-level folders in
  /// the zip are deleted first, so stale region files do not mix in.
  Future<void> restore(
    String zipPath, {
    required bool replace,
    required void Function(BackupProgress) onProgress,
  }) async {
    final input = InputFileStream(zipPath);
    try {
      final archive = ZipDecoder().decodeStream(input);
      final entries = [
        for (final e in archive)
          if (e.isFile)
            if (safeEntryPath(e.name) case final path?) (path, e),
      ];
      if (replace) {
        for (final top in {
          for (final (path, _) in entries)
            if (path.contains('/')) path.split('/').first,
        }) {
          _check();
          onProgress(BackupProgress(files: 0, totalFiles: entries.length, bytes: 0, current: 'Deleting $top'));
          try {
            await client.deleteFile(serverId, top);
          } on ExarotonException catch (e) {
            if (e.statusCode != 404) rethrow;
          }
        }
      }
      final made = <String>{};
      var bytes = 0;
      for (var i = 0; i < entries.length; i++) {
        _check();
        final (path, entry) = entries[i];
        onProgress(BackupProgress(files: i, totalFiles: entries.length, bytes: bytes, current: path));
        _check();
        // Parents first, top down.
        final dir = p.posix.dirname(path);
        if (dir != '.') {
          final parts = dir.split('/');
          for (var j = 1; j <= parts.length; j++) {
            final d = parts.sublist(0, j).join('/');
            if (made.add(d)) {
              try {
                await client.createDirectory(serverId, d);
              } on ExarotonException {
                // Already there.
              }
            }
          }
        }
        final data = entry.readBytes() ?? const <int>[];
        await client.writeFile(serverId, path, data);
        bytes += data.length;
      }
      onProgress(BackupProgress(files: entries.length, totalFiles: entries.length, bytes: bytes));
    } finally {
      input.closeSync();
    }
  }
}
