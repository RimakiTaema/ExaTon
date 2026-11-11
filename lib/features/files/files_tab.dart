import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import '../config/config_tab.dart';
import '../../core/platform/save_file.dart';
import 'backups_ui.dart';
import '../../ui/app_icons.dart';

final fileInfoProvider = FutureProvider.autoDispose.family<FileInfo, (String, String)>(
  (ref, key) => requireClient(ref).getFileInfo(key.$1, key.$2),
);

class FilesTab extends ConsumerStatefulWidget {
  const FilesTab({super.key, required this.server});
  final Server server;

  @override
  ConsumerState<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends ConsumerState<FilesTab> {
  String _path = '';

  String get _id => widget.server.id;
  ExarotonClient get _client => ref.read(clientProvider)!;

  void _refresh() => ref.invalidate(fileInfoProvider((_id, _path)));

  String _join(String name) => _path.isEmpty ? name : '$_path/$name';

  Future<void> _guard(Future<void> Function() f, [String? done]) async {
    try {
      await f();
      if (done != null && mounted) showMessage(context, done);
    } on ExarotonException catch (e) {
      if (mounted) showMessage(context, e.isTooLarge ? 'That file is too large for the API.' : e.message);
    }
  }

  Future<String?> _ask(String title, String hint) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Create')),
        ],
      ),
    ).whenComplete(c.dispose);
  }

  Future<void> _newFolder() async {
    final name = (await _ask('New folder', 'Folder name'))?.trim();
    if (name == null || name.isEmpty) return;
    await _guard(() => _client.createDirectory(_id, _join(name)), 'Folder created');
    _refresh();
  }

  Future<void> _newFile() async {
    final name = (await _ask('New file', 'File name'))?.trim();
    if (name == null || name.isEmpty) return;
    await _guard(() => _client.writeTextFile(_id, _join(name), ''), 'File created');
    _refresh();
  }

  Future<void> _upload() async {
    final file = await openFile();
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _guard(() => _client.writeFile(_id, _join(file.name), bytes), 'Uploaded ${file.name}');
    _refresh();
  }

  Future<void> _download(FileInfo f) async {
    // Read first: on phones the save dialog takes the bytes.
    await _guard(() async {
      final bytes = await _client.readFile(_id, f.path);
      final saved = await saveFileAs(f.name, bytes: bytes);
      if (saved != null && mounted) showMessage(context, 'Saved ${f.name}');
    });
  }

  Future<void> _delete(FileInfo f) async {
    final ok = await confirm(
      context,
      title: 'Delete ${f.name}?',
      body: f.isDirectory ? 'This deletes the folder and everything in it.' : 'This cannot be undone.',
      action: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    await _guard(() => _client.deleteFile(_id, f.path), 'Deleted ${f.name}');
    _refresh();
  }

  void _open(FileInfo f) {
    if (f.isDirectory) {
      setState(() => _path = f.path.replaceAll(RegExp(r'^/+|/+$'), ''));
      return;
    }
    if (f.isConfigFile) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(f.name)),
            body: Padding(
              padding: const EdgeInsets.all(gutter),
              child: ConfigTab(server: widget.server, initialPath: f.path, fixedPath: true),
            ),
          ),
        ),
      );
      return;
    }
    if (f.isTextFile || f.isLog) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TextFileEditor(serverId: _id, file: f),
        ),
      );
      return;
    }
    _download(f);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final info = ref.watch(fileInfoProvider((_id, _path)));
    final parts = _path.isEmpty ? <String>[] : _path.split('/');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TextButton(onPressed: () => setState(() => _path = ''), child: const Text('Files')),
                    for (var i = 0; i < parts.length; i++) ...[
                      Icon(AppIcons.next, color: t.onSurfaceMuted, size: 18),
                      TextButton(
                        onPressed: () => setState(() => _path = parts.sublist(0, i + 1).join('/')),
                        child: Text(parts[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'New or upload',
              icon: const Icon(AppIcons.add),
              onSelected: (v) => switch (v) {
                'folder' => _newFolder(),
                'file' => _newFile(),
                'backup' => backupFlow(context, _client, widget.server),
                'restore' => restoreFlow(context, _client, widget.server).then((_) => _refresh()),
                _ => _upload(),
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'folder', child: Text('New folder')),
                PopupMenuItem(value: 'file', child: Text('New file')),
                PopupMenuItem(value: 'upload', child: Text('Upload file')),
                PopupMenuDivider(),
                PopupMenuItem(value: 'backup', child: Text('Back up worlds')),
                PopupMenuItem(value: 'restore', child: Text('Restore a backup')),
              ],
            ),
            IconButton(tooltip: 'Refresh', icon: const Icon(AppIcons.refresh), onPressed: _refresh),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: switch (info) {
            AsyncData(:final value) => () {
              final children = [...?value.children]
                ..sort((a, b) {
                  if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
                  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                });
              if (children.isEmpty) {
                return Center(
                  child: Text('This folder is empty', style: TextStyle(color: t.onSurfaceMuted)),
                );
              }
              return ListView(
                children: [
                  CardList(
                    children: [
                      for (final f in children)
                        ListTile(
                          leading: Icon(
                            f.isDirectory
                                ? AppIcons.folder
                                : f.isConfigFile
                                ? AppIcons.configFile
                                : f.isTextFile || f.isLog
                                ? AppIcons.textFile
                                : AppIcons.file,
                            color: f.isDirectory ? t.primary : t.onSurfaceMuted,
                          ),
                          title: Text(f.name),
                          subtitle: f.isDirectory ? null : Text(formatBytes(f.size)),
                          onTap: f.isReadable || f.isDirectory ? () => _open(f) : null,
                          trailing: PopupMenuButton<String>(
                            tooltip: 'Actions for ${f.name}',
                            onSelected: (v) => v == 'delete' ? _delete(f) : _download(f),
                            itemBuilder: (_) => [
                              if (!f.isDirectory) const PopupMenuItem(value: 'download', child: Text('Download')),
                              PopupMenuItem(value: 'delete', enabled: f.isWritable, child: const Text('Delete')),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }(),
            AsyncError(:final error) => ErrorPanel(error, onRetry: _refresh),
            _ => const Loading(),
          },
        ),
      ],
    );
  }
}

class TextFileEditor extends ConsumerStatefulWidget {
  const TextFileEditor({super.key, required this.serverId, required this.file});
  final String serverId;
  final FileInfo file;

  @override
  ConsumerState<TextFileEditor> createState() => _TextFileEditorState();
}

class _TextFileEditorState extends ConsumerState<TextFileEditor> {
  final _c = TextEditingController();
  String? _original;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    ref
        .read(clientProvider)!
        .readTextFile(widget.serverId, widget.file.path)
        .then(
          (v) {
            if (!mounted) return;
            setState(() {
              _original = v;
              _c.text = v;
            });
          },
          onError: (Object e) {
            if (mounted) setState(() => _error = e);
          },
        );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(clientProvider)!.writeTextFile(widget.serverId, widget.file.path, _c.text);
      _original = _c.text;
      if (mounted) showMessage(context, 'Saved ${widget.file.name}');
    } on ExarotonException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final writable = widget.file.isWritable && !widget.file.isLog;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        actions: [
          if (writable && _original != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ValueListenableBuilder(
                valueListenable: _c,
                builder: (_, v, _) =>
                    FilledButton(onPressed: _saving || v.text == _original ? null : _save, child: const Text('Save')),
              ),
            ),
        ],
      ),
      body: _error != null
          ? ErrorPanel(_error!)
          : _original == null
          ? const Loading()
          : Padding(
              padding: const EdgeInsets.all(gutter),
              child: TextField(
                controller: _c,
                readOnly: !writable,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: monoFont, fontSize: 14),
              ),
            ),
    );
  }
}
