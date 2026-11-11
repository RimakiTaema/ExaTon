import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:exaton/features/files/backups.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';

Map<String, Object?> dir(String path, List<Map<String, Object?>> children) =>
    ok({'path': '/$path', 'name': path.split('/').last, 'isDirectory': true, 'children': children});

Map<String, Object?> entry(String name, {bool isDirectory = false, int size = 1}) => {
  'name': name,
  'path': name,
  'isDirectory': isDirectory,
  'size': size,
  'isReadable': true,
  'isWritable': true,
};

void main() {
  late Directory tmp;
  setUp(() async => tmp = await Directory.systemTemp.createTemp('exaton-backup-test'));
  tearDown(() => tmp.delete(recursive: true));

  test('level name and default folders', () {
    expect(levelName('motd=hi\nlevel-name=survival\n'), 'survival');
    expect(levelName('level-name=\n'), 'world');
    expect(levelName(null), 'world');
    expect(defaultWorldFolders(['world', 'world_nether', 'plugins', 'worldedit'], 'world'), {'world', 'world_nether'});
  });

  test('unsafe zip paths are refused', () {
    expect(safeEntryPath('world/level.dat'), 'world/level.dat');
    expect(safeEntryPath('world\\region\\r.0.0.mca'), 'world/region/r.0.0.mca');
    expect(safeEntryPath('../etc/passwd'), isNull);
    expect(safeEntryPath('world/../../x'), isNull);
    expect(safeEntryPath('/abs'), isNull);
    expect(safeEntryPath('C:/x'), isNull);
  });

  test('backs up nested folders, skipping session.lock', () async {
    final api = FakeAdapter({
      'GET /servers/abc/files/info/world/': (
        200,
        dir('world', [entry('level.dat'), entry('session.lock'), entry('region', isDirectory: true)]),
      ),
      'GET /servers/abc/files/info/world/region/': (200, dir('world/region', [entry('r.0.0.mca')])),
      'GET /servers/abc/files/data/world/level.dat/': (200, Uint8List.fromList([1, 2])),
      'GET /servers/abc/files/data/world/region/r.0.0.mca/': (200, Uint8List.fromList([3, 4, 5])),
    });
    final zipPath = '${tmp.path}/b.zip';
    final seen = <BackupProgress>[];
    await BackupEngine(fakeClient(api), 'abc').backup(['world'], zipPath, seen.add);

    final input = InputFileStream(zipPath);
    final archive = ZipDecoder().decodeStream(input);
    final files = {for (final f in archive) f.name: f.readBytes()};
    input.closeSync();
    expect(files.keys, unorderedEquals(['world/level.dat', 'world/region/r.0.0.mca']));
    expect(files['world/region/r.0.0.mca'], [3, 4, 5]);
    expect(seen.last.bytes, 5);
    expect(api.requests.any((r) => r.uri.path.contains('session.lock') && r.uri.path.contains('/data/')), isFalse);
    expect(BackupEngine.topFolders(zipPath), {'world'});
  });

  test('restore deletes the folder, makes parents, then uploads', () async {
    final zipPath = '${tmp.path}/r.zip';
    final enc = ZipFileEncoder()..create(zipPath);
    enc.addArchiveFile(ArchiveFile.bytes('world/level.dat', [1]));
    enc.addArchiveFile(ArchiveFile.bytes('world/region/r.0.0.mca', [2, 3]));
    enc.addArchiveFile(ArchiveFile.bytes('../evil.txt', [9]));
    await enc.close();

    final api = FakeAdapter({
      'DELETE /servers/abc/files/data/world/': (200, ok(null)),
      'PUT /servers/abc/files/data/world/': (200, ok(null)),
      'PUT /servers/abc/files/data/world/region/': (200, ok(null)),
      'PUT /servers/abc/files/data/world/level.dat/': (200, ok(null)),
      'PUT /servers/abc/files/data/world/region/r.0.0.mca/': (200, ok(null)),
    });
    await BackupEngine(fakeClient(api), 'abc').restore(zipPath, replace: true, onProgress: (_) {});
    expect(api.requests.map((r) => '${r.method} ${r.uri.path.replaceFirst('/v1/servers/abc/files/data/', '')}'), [
      'DELETE world/',
      'PUT world/',
      'PUT world/level.dat/',
      'PUT world/region/',
      'PUT world/region/r.0.0.mca/',
    ]);
  });

  test('cancel stops a backup and removes the partial zip', () async {
    final api = FakeAdapter({
      'GET /servers/abc/files/info/world/': (200, dir('world', [entry('a'), entry('b')])),
      'GET /servers/abc/files/data/world/a/': (200, Uint8List.fromList([1])),
      'GET /servers/abc/files/data/world/b/': (200, Uint8List.fromList([1])),
    });
    final engine = BackupEngine(fakeClient(api), 'abc');
    final zipPath = '${tmp.path}/c.zip';
    await expectLater(
      engine.backup(['world'], zipPath, (p) {
        if (p.files == 1) engine.cancel();
      }),
      throwsA(isA<BackupCancelled>()),
    );
    expect(File(zipPath).existsSync(), isFalse);
  });
}
