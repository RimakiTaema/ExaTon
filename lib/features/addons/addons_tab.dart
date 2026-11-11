import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../core/modrinth/modrinth.dart';
import '../../ui/app_icons.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import 'addons.dart';

/// Browse Modrinth and manage what is in the server's mods or plugins
/// folder. Shown for software that takes mods or plugins.
class AddonsTab extends ConsumerStatefulWidget {
  const AddonsTab({super.key, required this.server});
  final Server server;

  @override
  ConsumerState<AddonsTab> createState() => _AddonsTabState();
}

class _AddonsTabState extends ConsumerState<AddonsTab> {
  bool _browse = true;
  String? _pickedLoader;

  @override
  Widget build(BuildContext context) {
    final base = addonTargetOf(widget.server);
    if (base == null) {
      return const EmptyState(icon: AppIcons.noResults, title: 'This software does not take mods or plugins');
    }
    // Modpacks do not name their loader: the user picks one.
    final target = base.loaders.isEmpty ? base.withLoaders([_pickedLoader ?? base.kind.choices.first]) : base;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: true, label: Text('Browse')),
                ButtonSegment(value: false, label: Text('Installed')),
              ],
              selected: {_browse},
              onSelectionChanged: (s) => setState(() => _browse = s.first),
            ),
            if (base.loaders.isEmpty)
              DropdownButton<String>(
                value: target.loaders.first,
                items: [for (final l in base.kind.choices) DropdownMenuItem(value: l, child: Text(_loaderLabel(l)))],
                onChanged: (v) => setState(() => _pickedLoader = v),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _browse
              ? _BrowseView(server: widget.server, target: target)
              : _InstalledView(server: widget.server, target: target),
        ),
      ],
    );
  }
}

String _loaderLabel(String l) => switch (l) {
  'neoforge' => 'NeoForge',
  'bungeecord' => 'BungeeCord',
  _ => l[0].toUpperCase() + l.substring(1),
};

String _targetLabel(AddonTarget t) =>
    [t.loaders.map(_loaderLabel).join(', '), ?t.gameVersion].where((x) => x.isNotEmpty).join(' - ');

String _modrinthError(Object e) => switch (e) {
  ModrinthException(:final message) => message,
  ExarotonException(:final message, :final isTooLarge) => isTooLarge ? 'The file is too large for the API.' : message,
  _ => 'Something went wrong',
};

String _formatCount(int n) => n >= 1000000
    ? '${(n / 1000000).toStringAsFixed(1)}M'
    : n >= 1000
    ? '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k'
    : '$n';

class _BrowseView extends ConsumerStatefulWidget {
  const _BrowseView({required this.server, required this.target});
  final Server server;
  final AddonTarget target;

  @override
  ConsumerState<_BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends ConsumerState<_BrowseView> {
  final _query = TextEditingController();
  Timer? _debounce;
  bool _anyVersion = false;
  List<ModrinthProject> _hits = const [];
  int _total = 0;
  bool _loading = false;
  Object? _error;
  int _generation = 0;
  final _busy = <String>{};

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void didUpdateWidget(_BrowseView old) {
    super.didUpdateWidget(old);
    if (old.target.loaders.join() != widget.target.loaders.join()) _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  Future<void> _search({bool more = false}) async {
    final gen = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      if (!more) _hits = const [];
    });
    try {
      final page = await ref
          .read(modrinthClientProvider)
          .search(widget.target, query: _query.text, anyVersion: _anyVersion, offset: more ? _hits.length : 0);
      if (!mounted || gen != _generation) return;
      setState(() {
        _hits = [..._hits, ...page.hits];
        _total = page.total;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || gen != _generation) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _onQuery(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  Future<void> _install(ModrinthProject p) async {
    final installer = ref.read(addonInstallerProvider(widget.server.id));
    if (installer == null || _busy.contains(p.id)) return;
    setState(() => _busy.add(p.id));
    try {
      final version = await installer.bestVersion(p.id, widget.target);
      if (version == null) {
        if (mounted) showMessage(context, 'No version of ${p.title} for ${_targetLabel(widget.target)}');
        return;
      }
      final plan = await installer.plan(version, widget.target);
      final deps = plan.where((v) => v.projectId != p.id).toList();
      final projects = {
        p.id: p,
        for (final d in await ref.read(modrinthClientProvider).projects(deps.map((v) => v.projectId))) d.id: d,
      };
      if (!mounted) return;
      final ok = await confirm(
        context,
        title: 'Install ${p.title}?',
        body: [
          '${version.versionNumber} goes into /${widget.target.folder}.',
          if (deps.isNotEmpty)
            'It needs ${deps.map((d) => projects[d.projectId]?.title ?? d.name).join(', ')}, which will be installed too.',
          if (widget.server.status == ServerStatus.online) 'Restart the server to load it.',
        ].join('\n\n'),
        action: deps.isEmpty ? 'Install' : 'Install ${plan.length}',
      );
      if (!ok || !mounted) return;
      await installer.install(plan, widget.target, projects: projects);
      if (mounted) showMessage(context, 'Installed ${p.title}');
      ref.invalidate(_installedProvider((widget.server.id, widget.target.folder)));
    } catch (e) {
      if (mounted) showMessage(context, _modrinthError(e), tone: Tone.error);
    } finally {
      if (mounted) setState(() => _busy.remove(p.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final installed = ref.watch(_installedProvider((widget.server.id, widget.target.folder))).value;
    final installedIds = {...?installed?.tracked.values.map((a) => a.projectId)};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _query,
          onChanged: _onQuery,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: 'Search ${widget.target.kind.label.toLowerCase()} on Modrinth',
            prefixIcon: const Icon(AppIcons.search),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'For ${_targetLabel(widget.target)}',
                style: TextStyle(color: t.onSurfaceMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.target.gameVersion != null)
              FilterChip(
                label: const Text('Any version'),
                selected: _anyVersion,
                onSelected: (v) {
                  setState(() => _anyVersion = v);
                  _search();
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _error != null && _hits.isEmpty
              ? EmptyState(
                  icon: AppIcons.offline,
                  title: _modrinthError(_error!),
                  actions: [FilledButton(onPressed: _search, child: const Text('Try again'))],
                )
              : _hits.isEmpty && _loading
              ? const Loading()
              : _hits.isEmpty
              ? const EmptyState(icon: AppIcons.noResults, title: 'Nothing found')
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _hits.length + (_hits.length < _total ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _hits.length) {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator()
                              : OutlinedButton(onPressed: () => _search(more: true), child: const Text('Load more')),
                        ),
                      );
                    }
                    final p = _hits[i];
                    final has = installedIds.contains(p.id);
                    final busy = _busy.contains(p.id);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: _ProjectIcon(url: p.iconUrl),
                      title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        '${p.description}\n${[?p.author, '${_formatCount(p.downloads)} downloads'].join(' - ')}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      onLongPress: () => launchUrl(p.pageUrl, mode: LaunchMode.externalApplication),
                      trailing: busy
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : has
                          ? Tooltip(
                              message: 'Installed',
                              child: Icon(AppIcons.check, color: t.primary),
                            )
                          : IconButton(
                              tooltip: 'Install ${p.title}',
                              icon: const Icon(AppIcons.add),
                              onPressed: () => _install(p),
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ProjectIcon extends StatelessWidget {
  const _ProjectIcon({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fallback = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: t.background,
        border: Border.all(color: t.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(AppIcons.file, color: t.onSurfaceMuted),
    );
    if (url == null) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(url!, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
    );
  }
}

/// The folder listing joined with what ExaTon installed.
class _InstalledState {
  const _InstalledState({required this.files, required this.tracked});
  final List<FileInfo> files;
  final Map<String, InstalledAddon> tracked;
}

/// Keyed by server ID and folder.
final _installedProvider = FutureProvider.autoDispose.family<_InstalledState, (String, String)>((ref, key) async {
  final (serverId, kindFolder) = key;
  final installer = ref.watch(addonInstallerProvider(serverId));
  if (installer == null) return const _InstalledState(files: [], tracked: {});
  final server = installer.exaroton;
  List<FileInfo> files;
  try {
    final info = await server.getFileInfo(serverId, kindFolder);
    files = [...?info.children?.where((f) => !f.isDirectory && f.name.toLowerCase().endsWith('.jar'))]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  } on ExarotonException catch (e) {
    if (e.statusCode != 404) rethrow;
    files = const []; // No folder yet.
  }
  await installer.forgetMissing({for (final f in files) '$kindFolder/${f.name}'});
  return _InstalledState(files: files, tracked: await installer.installed());
});

class _InstalledView extends ConsumerStatefulWidget {
  const _InstalledView({required this.server, required this.target});
  final Server server;
  final AddonTarget target;

  @override
  ConsumerState<_InstalledView> createState() => _InstalledViewState();
}

class _InstalledViewState extends ConsumerState<_InstalledView> {
  Map<String, ModrinthVersion>? _updates;
  bool _checking = false;
  final _busy = <String>{};

  String get _id => widget.server.id;
  (String, String) get _key => (_id, widget.target.folder);

  Future<void> _check() async {
    final installer = ref.read(addonInstallerProvider(_id));
    if (installer == null) return;
    setState(() => _checking = true);
    try {
      final u = await installer.findUpdates(widget.target);
      if (!mounted) return;
      setState(() => _updates = u);
      showMessage(
        context,
        u.isEmpty ? 'Everything is up to date' : '${u.length} update${u.length == 1 ? '' : 's'} available',
      );
    } catch (e) {
      if (mounted) showMessage(context, _modrinthError(e), tone: Tone.error);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _run(String path, Future<void> Function(AddonInstaller i) f, String done) async {
    final installer = ref.read(addonInstallerProvider(_id));
    if (installer == null || _busy.contains(path)) return;
    setState(() => _busy.add(path));
    try {
      await f(installer);
      if (mounted) showMessage(context, done);
      ref.invalidate(_installedProvider(_key));
    } catch (e) {
      if (mounted) showMessage(context, _modrinthError(e), tone: Tone.error);
    } finally {
      if (mounted) setState(() => _busy.remove(path));
    }
  }

  Future<void> _update(String path, ModrinthVersion v) async {
    await _run(path, (i) => i.update(path, v, widget.target), 'Updated to ${v.versionNumber}');
    if (mounted) setState(() => _updates?.remove(path));
  }

  Future<void> _updateAll() async {
    for (final e in [...?_updates?.entries]) {
      if (!mounted) return;
      await _update(e.key, e.value);
    }
  }

  Future<void> _remove(String path, String name) async {
    final ok = await confirm(
      context,
      title: 'Remove $name?',
      body: 'This deletes /$path from the server.',
      action: 'Remove',
      destructive: true,
    );
    if (!ok) return;
    await _run(path, (i) => i.remove(path), 'Removed $name');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final folder = widget.target.folder;
    final state = ref.watch(_installedProvider(_key));
    final updates = _updates ?? const {};
    return switch (state) {
      AsyncData(:final value) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${value.files.length} in /$folder', style: TextStyle(color: t.onSurfaceMuted)),
              ),
              if (updates.isNotEmpty)
                TextButton(onPressed: _busy.isEmpty ? _updateAll : null, child: Text('Update all (${updates.length})')),
              OutlinedButton(
                onPressed: _checking ? null : _check,
                child: Text(_checking ? 'Checking...' : 'Check for updates'),
              ),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(AppIcons.refresh),
                onPressed: () => ref.invalidate(_installedProvider(_key)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (value.files.isEmpty)
            Expanded(
              child: EmptyState(
                icon: AppIcons.folder,
                title: 'No ${widget.target.kind.label.toLowerCase()} yet',
                body: 'Find some under Browse.',
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  CardList(
                    children: [
                      for (final f in value.files)
                        () {
                          final path = '$folder/${f.name}';
                          final a = value.tracked[path];
                          final update = updates[path];
                          final busy = _busy.contains(path);
                          return ListTile(
                            leading: _ProjectIcon(url: a?.iconUrl),
                            title: Text(a?.title ?? f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              [
                                if (a != null) a.versionNumber else 'Not installed by ExaTon',
                                formatBytes(f.size),
                                if (update != null) 'Update: ${update.versionNumber}',
                              ].join(' - '),
                              style: TextStyle(color: update != null ? t.primary : t.onSurfaceMuted),
                            ),
                            trailing: busy
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (update != null)
                                        IconButton(
                                          tooltip: 'Update ${a?.title ?? f.name}',
                                          icon: Icon(AppIcons.refresh, color: t.primary),
                                          onPressed: () => _update(path, update),
                                        ),
                                      IconButton(
                                        tooltip: 'Remove ${a?.title ?? f.name}',
                                        icon: const Icon(AppIcons.delete),
                                        onPressed: f.isWritable ? () => _remove(path, a?.title ?? f.name) : null,
                                      ),
                                    ],
                                  ),
                          );
                        }(),
                    ],
                  ),
                  if (widget.server.status == ServerStatus.online)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: InfoNote('Changes load the next time the server starts.'),
                    ),
                ],
              ),
            ),
        ],
      ),
      AsyncError(:final error) => ErrorPanel(error, onRetry: () => ref.invalidate(_installedProvider(_key))),
      _ => const Loading(),
    };
  }
}
