import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../core/platform/save_file.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import 'backups.dart';

/// Picks folders, zips them and asks where to save the zip.
Future<void> backupFlow(BuildContext context, ExarotonClient client, Server server) async {
  final List<String> folders;
  final String level;
  try {
    final root = await client.getFileInfo(server.id, '');
    folders = [
      for (final c in root.children ?? const <FileInfo>[])
        if (c.isDirectory) c.name,
    ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    String? props;
    try {
      props = await client.readTextFile(server.id, 'server.properties');
    } on ExarotonException {
      // No server.properties (a proxy, say): fall back to "world".
    }
    level = levelName(props);
  } on ExarotonException catch (e) {
    if (context.mounted) showMessage(context, e.message, tone: Tone.error);
    return;
  }
  if (!context.mounted) return;
  if (folders.isEmpty) {
    showMessage(context, 'There are no folders to back up');
    return;
  }
  final choice = await showDialog<(List<String>, bool)>(
    context: context,
    builder: (_) => _BackupDialog(
      folders: folders,
      preselected: defaultWorldFolders(folders, level),
      online: server.status == ServerStatus.online,
    ),
  );
  if (choice == null || !context.mounted) return;
  final (picked, saveFirst) = choice;

  if (saveFirst) {
    try {
      await client.sendCommand(server.id, 'save-all flush');
      // The server writes chunks after it answers.
      await Future<void>.delayed(const Duration(seconds: 5));
    } on ExarotonException catch (e) {
      if (context.mounted) showMessage(context, 'Could not save the world first: ${e.message}', tone: Tone.error);
      return;
    }
  }
  if (!context.mounted) return;

  final stamp = DateFormat('yyyy-MM-dd-HHmm').format(DateTime.now());
  final safeName = server.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-');
  final name = '$safeName-$stamp.zip';
  final tmp = File('${(await getTemporaryDirectory()).path}/exaton-$name');
  if (!context.mounted) return;
  final engine = BackupEngine(client, server.id);
  final ok = await _runWithProgress(
    context,
    title: 'Backing up ${picked.join(', ')}',
    engine: engine,
    run: (progress) => engine.backup(picked, tmp.path, progress),
  );
  try {
    if (!ok || !context.mounted) return;
    final saved = await saveFileAs(name, sourcePath: tmp.path);
    if (saved != null && context.mounted) showMessage(context, 'Backup saved');
  } finally {
    try {
      if (await tmp.exists()) await tmp.delete();
    } catch (_) {}
  }
}

/// Uploads a backup zip to a stopped server.
Future<void> restoreFlow(BuildContext context, ExarotonClient client, Server server) async {
  if (server.status != ServerStatus.offline) {
    showMessage(context, 'Stop the server before restoring a backup');
    return;
  }
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(
        label: 'Zip',
        extensions: ['zip'],
        mimeTypes: ['application/zip'],
        uniformTypeIdentifiers: ['public.zip-archive'],
      ),
    ],
  );
  if (file == null || !context.mounted) return;
  final Set<String> tops;
  try {
    tops = BackupEngine.topFolders(file.path);
  } catch (_) {
    showMessage(context, "That file isn't a zip ExaTon can read");
    return;
  }
  if (tops.isEmpty) {
    showMessage(context, 'The zip has no folders to restore');
    return;
  }
  final replace = await showDialog<bool>(
    context: context,
    builder: (_) => _RestoreDialog(serverName: server.name, folders: tops.toList()..sort()),
  );
  if (replace == null || !context.mounted) return;
  final engine = BackupEngine(client, server.id);
  final ok = await _runWithProgress(
    context,
    title: 'Restoring ${tops.join(', ')}',
    engine: engine,
    run: (progress) => engine.restore(file.path, replace: replace, onProgress: progress),
  );
  if (ok && context.mounted) showMessage(context, 'Backup restored');
}

class _BackupDialog extends StatefulWidget {
  const _BackupDialog({required this.folders, required this.preselected, required this.online});
  final List<String> folders;
  final Set<String> preselected;
  final bool online;

  @override
  State<_BackupDialog> createState() => _BackupDialogState();
}

class _BackupDialogState extends State<_BackupDialog> {
  late final _picked = {...widget.preselected};
  late bool _save = widget.online;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AlertDialog(
      title: const Text('Back up folders'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Downloads the folders as a zip to this device. Large worlds can take a while.',
                style: TextStyle(color: t.onSurfaceMuted, height: 1.4),
              ),
              const SizedBox(height: 8),
              for (final f in widget.folders)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(f),
                  value: _picked.contains(f),
                  onChanged: (v) => setState(() => v == true ? _picked.add(f) : _picked.remove(f)),
                ),
              if (widget.online) ...[
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Save the world first'),
                  subtitle: const Text('Runs save-all so the backup has the latest chunks'),
                  value: _save,
                  onChanged: (v) => setState(() => _save = v),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _picked.isEmpty
              ? null
              : () => Navigator.pop(context, (
                  [
                    for (final f in widget.folders)
                      if (_picked.contains(f)) f,
                  ],
                  _save,
                )),
          child: const Text('Back up'),
        ),
      ],
    );
  }
}

class _RestoreDialog extends StatefulWidget {
  const _RestoreDialog({required this.serverName, required this.folders});
  final String serverName;
  final List<String> folders;

  @override
  State<_RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<_RestoreDialog> {
  bool _replace = true;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AlertDialog(
      title: Text('Restore to ${widget.serverName}?'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Uploads: ${widget.folders.join(', ')}', style: const TextStyle(height: 1.4)),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Delete these folders first'),
              subtitle: const Text('Recommended. Otherwise files not in the backup stay.'),
              value: _replace,
              onChanged: (v) => setState(() => _replace = v ?? true),
            ),
            const SizedBox(height: 4),
            WarningBanner(
              _replace
                  ? 'The current folders are deleted. This cannot be undone.'
                  : 'Files with the same names are overwritten.',
              tone: Tone.error,
            ),
            const SizedBox(height: 4),
            Text('Keep the server stopped until it finishes.', style: TextStyle(color: t.onSurfaceMuted)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: t.error, foregroundColor: t.onError),
          onPressed: () => Navigator.pop(context, _replace),
          child: const Text('Restore'),
        ),
      ],
    );
  }
}

/// Shows progress while [run] works. True when it finished, false when it
/// failed or was cancelled (the reason is shown).
Future<bool> _runWithProgress(
  BuildContext context, {
  required String title,
  required BackupEngine engine,
  required Future<void> Function(void Function(BackupProgress)) run,
}) async {
  final progress = ValueNotifier(const BackupProgress(files: 0, totalFiles: 0, bytes: 0));
  Object? error;
  var cancelled = false;
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
          content: ValueListenableBuilder(
            valueListenable: progress,
            builder: (c, p, _) {
              final t = c.tokens;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: p.fraction),
                  const SizedBox(height: 12),
                  Text(
                    p.totalFiles == 0
                        ? 'Preparing...'
                        : '${p.files} of ${p.totalFiles} files - ${formatBytes(p.bytes)}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.current,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: t.onSurfaceMuted, fontSize: 13),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                cancelled = true;
                engine.cancel();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    ),
  );
  try {
    await run((p) => progress.value = p);
  } on BackupCancelled {
    cancelled = true;
  } catch (e) {
    error = e;
  } finally {
    // Not disposed: the dialog may still be animating out with it.
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
  if (!context.mounted) return false;
  if (cancelled) {
    showMessage(context, 'Cancelled');
    return false;
  }
  if (error != null) {
    showMessage(
      context,
      error is ExarotonException
          ? (error.isTooLarge ? 'A file is too large for the API' : error.message)
          : 'Something went wrong: $error',
    );
    return false;
  }
  return true;
}
