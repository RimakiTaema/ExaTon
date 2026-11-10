import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../ui/app_icons.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';

/// Everything `GET /software/` offers. Fetched when a picker opens.
final softwareListProvider = FutureProvider.autoDispose<List<Software>>((ref) => requireClient(ref).listSoftware());

/// What installing one software on one server would do.
final softwareDetailsProvider = FutureProvider.autoDispose.family<SoftwareDetails, (String, String)>(
  (ref, key) => requireClient(ref).getServerSoftware(key.$1, key.$2),
);

/// A pick from the software list: one exact version, or the latest version
/// of a software type.
@immutable
class SoftwareChoice {
  const SoftwareChoice.version(Software this.software) : latestType = null;
  const SoftwareChoice.latest(String this.latestType) : software = null;

  final Software? software;
  final String? latestType;

  String get label => software?.toString() ?? 'Latest $latestType';
}

/// The software types in [list], in first-seen order.
List<String> softwareTypes(List<Software> list) => {
  for (final s in list)
    if (s.type.isNotEmpty) s.type,
}.toList();

/// [list] narrowed to one [type] (null for all) and a search [query] over
/// name, version, type and launcher.
List<Software> filterSoftware(List<Software> list, {String? type, String query = ''}) {
  final q = query.trim().toLowerCase();
  return list.where((s) {
    if (type != null && s.type != type) return false;
    if (q.isEmpty) return true;
    return '${s.name} ${s.version} ${s.type} ${s.launcher ?? ''}'.toLowerCase().contains(q);
  }).toList();
}

/// What to tell the user when creating a server failed. A 413 is the
/// account's server limit, named with [maxServers] when it is known.
String createServerError(Object error, {int? maxServers}) {
  if (error is ServerLimitReachedException) {
    return maxServers == null ? 'Server limit reached' : 'Server limit reached ($maxServers max)';
  }
  if (error is ExarotonException) return error.message;
  return 'Could not create the server';
}

/// Full-screen software list with search and a type filter. Pops with a
/// [SoftwareChoice]. [allowLatest] adds a "Latest" row per type.
class SoftwarePickerPage extends ConsumerStatefulWidget {
  const SoftwarePickerPage({super.key, this.allowLatest = false, this.currentId});
  final bool allowLatest;

  /// The installed software, marked in the list.
  final String? currentId;

  @override
  ConsumerState<SoftwarePickerPage> createState() => _SoftwarePickerPageState();
}

class _SoftwarePickerPageState extends ConsumerState<SoftwarePickerPage> {
  String _query = '';
  String? _type;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final list = ref.watch(softwareListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose software')),
      body: SafeArea(
        child: switch (list) {
          AsyncData(:final value) => () {
            final types = softwareTypes(value);
            final shown = filterSoftware(value, type: _type, query: _query);
            final q = _query.trim().toLowerCase();
            final latest = widget.allowLatest
                ? [
                    for (final type in types)
                      if ((_type == null || _type == type) && (q.isEmpty || type.toLowerCase().contains(q))) type,
                  ]
                : const <String>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(gutter, 4, gutter, 10),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Search software or version',
                      prefixIcon: Icon(AppIcons.search),
                    ),
                  ),
                ),
                if (types.length > 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: gutter),
                    child: Row(
                      children: [
                        for (final type in <String?>[null, ...types])
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(type ?? 'All'),
                              selected: _type == type,
                              labelStyle: TextStyle(
                                color: _type == type ? t.background : t.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                              onSelected: (_) => setState(() => _type = type),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: latest.isEmpty && shown.isEmpty
                      ? EmptyState(
                          icon: AppIcons.noResults,
                          title: value.isEmpty ? 'No software available' : 'No software matches',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: latest.length + shown.length,
                          itemBuilder: (context, i) {
                            if (i < latest.length) {
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: gutter),
                                title: Text(
                                  'Latest ${latest[i]}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                                ),
                                subtitle: const Text('Newest version, chosen by exaroton'),
                                onTap: () => Navigator.pop(context, SoftwareChoice.latest(latest[i])),
                              );
                            }
                            final s = shown[i - latest.length];
                            final current = s.id == widget.currentId;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: gutter),
                              title: Text('$s', style: const TextStyle(fontSize: 17)),
                              subtitle: Text(
                                [s.type, ?s.launcher, if (current) 'installed'].where((x) => x.isNotEmpty).join(' - '),
                                style: TextStyle(color: current ? t.primary : t.onSurfaceMuted),
                              ),
                              trailing: current ? Icon(AppIcons.check, color: t.primary) : null,
                              onTap: () => Navigator.pop(context, SoftwareChoice.version(s)),
                            );
                          },
                        ),
                ),
              ],
            );
          }(),
          AsyncError(:final error) => ErrorPanel(error, onRetry: () => ref.invalidate(softwareListProvider)),
          _ => const Loading(),
        },
      ),
    );
  }
}

Future<SoftwareChoice?> pickSoftware(BuildContext context, {bool allowLatest = false, String? currentId}) =>
    Navigator.of(context).push<SoftwareChoice>(
      MaterialPageRoute(
        builder: (_) => SoftwarePickerPage(allowLatest: allowLatest, currentId: currentId),
      ),
    );

/// Shows what installing [software] on [server] would do. Pops with the
/// [SoftwareDetails] when the user chooses Install, null on Cancel.
class SoftwareDetailsDialog extends ConsumerWidget {
  const SoftwareDetailsDialog({super.key, required this.server, required this.software});
  final Server server;
  final Software software;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final details = ref.watch(softwareDetailsProvider((server.id, software.id)));
    final d = details.value;
    final link = d?.link == null ? null : Uri.tryParse(d!.link!);
    return AlertDialog(
      title: Text('$software'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: switch (details) {
            AsyncData(:final value) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [value.type, ?value.launcher].where((x) => x.isNotEmpty).join(' - '),
                  style: TextStyle(color: t.onSurfaceMuted),
                ),
                if (value.description != null && value.description!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(value.description!, style: const TextStyle(height: 1.4)),
                ],
                if (value.addons != null && value.addons!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('Supports: ${value.addons!.join(', ')}', style: TextStyle(color: t.onSurfaceMuted)),
                ],
                if (link != null && (link.isScheme('https') || link.isScheme('http'))) ...[
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: () => launchUrl(link, mode: LaunchMode.externalApplication),
                    icon: const Icon(AppIcons.openExternal, size: 18),
                    label: const Text('More information'),
                  ),
                ],
                const SizedBox(height: 12),
                if (value.reinstall)
                  const WarningBanner(
                    'Installing this needs a reinstall. Every file on the server is deleted.',
                    tone: Tone.error,
                  )
                else
                  Text('Your server files are kept.', style: TextStyle(color: t.onSurfaceMuted)),
              ],
            ),
            AsyncError(:final error) => Text(describeError(error).body, style: TextStyle(color: t.error)),
            _ => const SizedBox(height: 80, child: Loading()),
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: d == null ? null : () => Navigator.pop(context, d),
          child: Text(d?.reinstall == true ? 'Reinstall...' : 'Install'),
        ),
      ],
    );
  }
}

/// Opens the create-server dialog. Returns the new server, or null when the
/// user cancels. [maxServers] is used to word the limit error.
Future<Server?> showCreateServerDialog(BuildContext context, {int? maxServers}) => showDialog<Server>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _CreateServerDialog(maxServers: maxServers),
);

class _CreateServerDialog extends ConsumerStatefulWidget {
  const _CreateServerDialog({this.maxServers});
  final int? maxServers;

  @override
  ConsumerState<_CreateServerDialog> createState() => _CreateServerDialogState();
}

class _CreateServerDialogState extends ConsumerState<_CreateServerDialog> {
  final _name = TextEditingController();
  final _motd = TextEditingController();
  final _timezone = TextEditingController();
  SoftwareChoice? _software;
  String? _region;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _motd.dispose();
    _timezone.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty && _software != null;

  Future<void> _create() async {
    final client = ref.read(clientProvider);
    if (client == null || !_valid || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final server = await client.createServer(
        CreateServerRequest(
          name: _name.text,
          software: _software!.software?.id,
          softwareType: _software!.latestType,
          motd: _motd.text,
          timezone: _timezone.text,
          region: _region,
        ),
      );
      if (mounted) Navigator.pop(context, server);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = createServerError(e, maxServers: widget.maxServers);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 14);
    return AlertDialog(
      title: const Text('Add server'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                autofocus: true,
                autocorrect: false,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  helperText: 'Becomes the address, e.g. name.exaroton.me',
                ),
              ),
              const SizedBox(height: 14),
              Text('Software', style: label),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final c = await pickSoftware(context, allowLatest: true);
                        if (c != null && mounted) setState(() => _software = c);
                      },
                style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
                child: Row(
                  children: [
                    Expanded(child: Text(_software?.label ?? 'Choose software', overflow: TextOverflow.ellipsis)),
                    const Icon(AppIcons.next, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _motd,
                decoration: const InputDecoration(labelText: 'MOTD (optional)'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _timezone,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Time zone (optional)',
                  hintText: 'Europe/Berlin',
                  helperText: 'IANA name. UTC when empty.',
                ),
              ),
              const SizedBox(height: 14),
              Text('Region', style: label),
              const SizedBox(height: 6),
              SegmentedButton<String?>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: null, label: Text('Auto')),
                  ButtonSegment(value: 'eu', label: Text('Europe')),
                  ButtonSegment(value: 'na', label: Text('N. America')),
                ],
                selected: {_region},
                onSelectionChanged: (s) => setState(() => _region = s.first),
              ),
              if (_error != null) ...[const SizedBox(height: 14), WarningBanner(_error!, tone: Tone.error)],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _valid && !_saving ? _create : null,
          child: Text(_saving ? 'Creating...' : 'Create server'),
        ),
      ],
    );
  }
}
