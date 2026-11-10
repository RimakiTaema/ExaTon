import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import '../../ui/app_icons.dart';

final playerListsProvider = FutureProvider.autoDispose.family<List<String>, String>(
  (ref, id) => requireClient(ref).getPlayerLists(id),
);

final playerListProvider = FutureProvider.autoDispose.family<List<String>, (String, String)>(
  (ref, key) => requireClient(ref).getPlayerList(key.$1, key.$2),
);

/// Player lists (whitelist, ops, banned...). Changes are staged and applied
/// in one PUT and one DELETE, because each call is a storage operation.
class PlayersTab extends ConsumerStatefulWidget {
  const PlayersTab({super.key, required this.server});
  final Server server;

  @override
  ConsumerState<PlayersTab> createState() => _PlayersTabState();
}

class _PlayersTabState extends ConsumerState<PlayersTab> {
  String? _list;
  final _add = <String>{};
  final _remove = <String>{};
  final _input = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  bool get _dirty => _add.isNotEmpty || _remove.isNotEmpty;

  void _stage() {
    final names = _input.text.split(RegExp(r'[\s,]+')).where((n) => n.isNotEmpty);
    setState(() {
      for (final n in names) {
        if (!_remove.remove(n)) _add.add(n);
      }
      _input.clear();
    });
  }

  Future<void> _apply() async {
    final list = _list;
    final client = ref.read(clientProvider);
    if (list == null || client == null) return;
    setState(() => _saving = true);
    try {
      if (_add.isNotEmpty) await client.addToPlayerList(widget.server.id, list, _add.toList());
      if (_remove.isNotEmpty) await client.removeFromPlayerList(widget.server.id, list, _remove.toList());
      setState(() {
        _add.clear();
        _remove.clear();
      });
      ref.invalidate(playerListProvider((widget.server.id, list)));
      if (mounted) showMessage(context, 'Saved $list');
    } on ExarotonException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _switchList(String l) async {
    if (_dirty &&
        !await confirm(
          context,
          title: 'Discard changes?',
          body: 'You have unsaved changes to $_list.',
          action: 'Discard',
        )) {
      return;
    }
    setState(() {
      _list = l;
      _add.clear();
      _remove.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final lists = ref.watch(playerListsProvider(widget.server.id));
    return switch (lists) {
      AsyncError(:final error) => ErrorPanel(
        error,
        onRetry: () => ref.invalidate(playerListsProvider(widget.server.id)),
      ),
      AsyncData(:final value) when value.isEmpty => const Center(child: Text('This server has no player lists.')),
      AsyncData(:final value) => () {
        final list = _list ?? value.first;
        _list ??= list;
        final entries = ref.watch(playerListProvider((widget.server.id, list)));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final l in value)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(l),
                        selected: l == list,
                        labelStyle: TextStyle(
                          color: l == list ? t.background : t.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => _switchList(l),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    onSubmitted: (_) => _stage(),
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'Add players to $list',
                      prefixIcon: const Icon(AppIcons.addPlayer),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(onPressed: _stage, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: switch (entries) {
                AsyncData(:final value) => () {
                  final all = {...value, ..._add}.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                  if (all.isEmpty) {
                    return Center(
                      child: Text('$list is empty', style: TextStyle(color: t.onSurfaceMuted)),
                    );
                  }
                  return ListView(
                    children: [
                      CardList(
                        children: [
                          for (final p in all)
                            ListTile(
                              leading: Avatar(p, size: 34),
                              title: Text(
                                p,
                                style: TextStyle(
                                  decoration: _remove.contains(p) ? TextDecoration.lineThrough : null,
                                  color: _remove.contains(p) ? t.onSurfaceMuted : null,
                                ),
                              ),
                              subtitle: _add.contains(p)
                                  ? Text('Will be added', style: TextStyle(color: t.primary))
                                  : _remove.contains(p)
                                  ? Text('Will be removed', style: TextStyle(color: t.error))
                                  : null,
                              trailing: IconButton(
                                tooltip: _remove.contains(p) || _add.contains(p) ? 'Undo for $p' : 'Remove $p',
                                icon: Icon(
                                  _remove.contains(p) || _add.contains(p) ? AppIcons.undo : AppIcons.removeItem,
                                ),
                                onPressed: () => setState(() {
                                  if (_add.remove(p)) return;
                                  if (!_remove.remove(p)) _remove.add(p);
                                }),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                }(),
                AsyncError(:final error) => ErrorPanel(error),
                _ => const Loading(),
              },
            ),
            if (_dirty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_add.length} to add, ${_remove.length} to remove',
                      style: TextStyle(color: t.onSurfaceMuted),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _add.clear();
                      _remove.clear();
                    }),
                    child: const Text('Discard'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _saving ? null : _apply, child: const Text('Apply changes')),
                ],
              ),
            ],
          ],
        );
      }(),
      _ => const Loading(),
    };
  }
}
