import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/motion.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import '../accounts/add_account_screen.dart';
import '../credits/credits.dart';
import '../credits/estimate.dart';
import '../credits/top_up.dart';
import 'recent_servers.dart';
import 'server_actions.dart';
import 'server_form.dart';
import 'server_icon.dart';
import 'servers.dart';
import '../../ui/app_icons.dart';

/// Focus for the search field, so Ctrl K / ⌘ K can reach it from the shell.
final searchFocusProvider = Provider<FocusNode>((ref) {
  final f = FocusNode(debugLabel: 'server search');
  ref.onDispose(f.dispose);
  return f;
});

/// "⌘ K" on Apple platforms, "Ctrl K" elsewhere.
String searchShortcutLabel(BuildContext context) => switch (Theme.of(context).platform) {
  TargetPlatform.macOS || TargetPlatform.iOS => '⌘ K',
  _ => 'Ctrl K',
};

final _exarotonCreate = Uri.parse('https://exaroton.com/create/');

/// Server list. [onOpen] opens a server's detail; [dense] is the list pane
/// next to the detail on expanded windows.
class ServersScreen extends ConsumerWidget {
  const ServersScreen({super.key, required this.onOpen, this.dense = false});
  final void Function(Server) onOpen;
  final bool dense;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final account = ref.read(accountInfoProvider).value;
    final created = await showCreateServerDialog(context, maxServers: account?.maxServers);
    if (created == null) return;
    await ref.read(serversProvider.notifier).refresh();
    if (!context.mounted) return;
    showMessage(context, '${created.name} created');
    // Open it once the list has it, so the detail has a server to show.
    final inList = ref.read(serverByIdProvider(created.id));
    if (inList != null) onOpen(inList);
  }

  Future<void> _refresh(WidgetRef ref) async {
    refreshCredits(ref.invalidate);
    await ref.read(serversProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider);
    final (text, filter) = ref.watch(serverQueryProvider);
    final selected = ref.watch(selectedServerProvider);
    final sync = ref.watch(serversSyncProvider);
    final recentIds = [for (final r in ref.watch(recentServersProvider)) r.id];

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, dense ? 24 : 16, gutter, 0),
            sliver: SliverList.list(
              children: [
                _Header(
                  dense: dense,
                  sync: sync,
                  owned: servers.value?.where((s) => s.isOwner).length,
                  onRefresh: () => _refresh(ref),
                  onAdd: () => _add(context, ref),
                ),
                const SizedBox(height: 16),
                if (sync.error != null && servers.hasValue) ...[
                  WarningBanner(
                    sync.updated == null
                        ? "Can't reach exaroton. Retrying."
                        : "Can't reach exaroton. Showing data from ${formatClock(sync.updated!)}. Retrying.",
                    tone: Tone.warning,
                    action: TextButton(onPressed: () => _refresh(ref), child: const Text('Retry')),
                  ),
                  const SizedBox(height: 14),
                ],
                if (!dense) ...[const _CreditsSummary(), const SizedBox(height: 14)],
                _SearchField(dense: dense),
                const SizedBox(height: 12),
                if (dense) ...[const _CreditsSummary(dense: true), const SizedBox(height: 12)],
                if (!dense) ...[_FilterChips(servers.value ?? const [], filter, recentIds), const SizedBox(height: 14)],
              ],
            ),
          ),
          ...switch (servers) {
            AsyncData(:final value) => _list(context, ref, value, text, filter, selected, recentIds),
            AsyncError(:final error) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ServersError(error: error, onRetry: () => ref.invalidate(serversProvider)),
              ),
            ],
            _ => [_SkeletonList(dense: dense)],
          },
        ],
      ),
    );
  }

  List<Widget> _list(
    BuildContext context,
    WidgetRef ref,
    List<Server> value,
    String text,
    ServerFilter filter,
    String? selected,
    List<String> recentIds,
  ) {
    if (value.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: AppIcons.servers,
            title: 'No servers yet',
            body: 'Add a server here, or create one on exaroton and press Refresh.',
            actions: [
              FilledButton(onPressed: () => _add(context, ref), child: const Text('Add server')),
              OutlinedButton(
                onPressed: () => launchUrl(_exarotonCreate, mode: LaunchMode.externalApplication),
                child: const Text('Create on exaroton'),
              ),
            ],
          ),
        ),
      ];
    }
    final list = filterServers(value, text, filter, recentIds: recentIds);
    if (list.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: AppIcons.noResults,
            title: text.trim().isEmpty ? 'No ${filter.name} servers' : 'No servers match "${text.trim()}"',
            body: filter == ServerFilter.recent && text.trim().isEmpty ? 'Servers you open are listed here.' : null,
            actions: [
              OutlinedButton(
                onPressed: () {
                  ref.read(serverQueryProvider.notifier)
                    ..setText('')
                    ..setFilter(ServerFilter.all);
                },
                child: const Text('Show all servers'),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(gutter, 0, gutter, 24),
        sliver: SliverList.separated(
          itemCount: list.length,
          separatorBuilder: (_, _) => SizedBox(height: dense ? 10 : 14),
          itemBuilder: (_, i) => FadeSlideIn(
            key: ValueKey(list[i].id),
            index: i,
            onceKey: 'server:${list[i].id}',
            child: ServerCard(
              list[i],
              dense: dense,
              selected: dense && list[i].id == selected,
              onTap: () => onOpen(list[i]),
            ),
          ),
        ),
      ),
    ];
  }
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.dense,
    required this.sync,
    required this.owned,
    required this.onRefresh,
    required this.onAdd,
  });
  final bool dense;
  final ServersSync sync;

  /// Servers this account owns; null while the list loads.
  final int? owned;
  final VoidCallback onRefresh;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final account = ref.watch(activeAccountProvider);
    final maxServers = ref.watch(accountInfoProvider).value?.maxServers;
    final muted = TextStyle(color: t.onSurfaceMuted, fontSize: 15);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text('Servers', style: Theme.of(context).textTheme.headlineLarge)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                [
                  if (!dense && account != null) 'Signed in as ${account.name}',
                  if (owned != null && maxServers != null) '$owned / $maxServers servers',
                  if (sync.updated != null) 'Updated ${formatClock(sync.updated!)}',
                ].join(' - '),
                style: muted,
              ),
            ),
            IconButton(
              tooltip: 'Add server',
              icon: Icon(AppIcons.add, color: t.onSurfaceMuted),
              onPressed: onAdd,
            ),
            // Pull-to-refresh does not work with a mouse; this does.
            SizedBox(
              width: 44,
              height: 44,
              child: sync.refreshing
                  ? const Center(
                      child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2)),
                    )
                  : IconButton(
                      tooltip: 'Refresh',
                      icon: Icon(AppIcons.refresh, color: t.onSurfaceMuted),
                      onPressed: onRefresh,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServersError extends ConsumerWidget {
  const _ServersError({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = describeError(error);
    final account = ref.watch(activeAccountProvider);
    return ErrorPanel(
      error,
      onRetry: info.kind == ErrorKind.revoked ? null : onRetry,
      actions: [
        if (info.kind == ErrorKind.revoked) ...[
          FilledButton(
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddAccountScreen(popOnDone: true))),
            child: const Text('Sign in again'),
          ),
          if (account != null)
            OutlinedButton(
              onPressed: () async {
                final ok = await confirm(
                  context,
                  title: 'Remove ${account.name}?',
                  body: 'The saved token is deleted from this device.',
                  action: 'Remove account',
                  destructive: true,
                );
                if (ok) await ref.read(accountsProvider.notifier).remove(account.id);
              },
              child: const Text('Remove account'),
            ),
        ],
      ],
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({required this.dense});
  final bool dense;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(gutter, 0, gutter, 24),
    sliver: SliverList.separated(
      itemCount: 3,
      separatorBuilder: (_, _) => SizedBox(height: dense ? 10 : 14),
      itemBuilder: (_, _) => Semantics(
        label: 'Loading servers',
        child: AppCard(
          padding: EdgeInsets.fromLTRB(20, dense ? 16 : 18, 18, dense ? 16 : 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [Skeleton(width: 150, height: 20), SizedBox(width: 12), Skeleton(width: 64, height: 14)],
              ),
              const SizedBox(height: 12),
              if (dense)
                const Skeleton(width: 180, height: 14)
              else
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Skeleton(width: 170, height: 14),
                          SizedBox(height: 8),
                          Skeleton(width: 140, height: 14),
                        ],
                      ),
                    ),
                    Skeleton(width: actionButtonWidth(context), height: 44, radius: 14),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SearchField extends ConsumerWidget {
  const _SearchField({required this.dense});
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return TextField(
      focusNode: ref.watch(searchFocusProvider),
      onChanged: ref.read(serverQueryProvider.notifier).setText,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search servers',
        prefixIcon: const Icon(AppIcons.search),
        suffixIcon: dense
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: t.outlineStrong),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(searchShortcutLabel(context), style: TextStyle(color: t.onSurfaceMuted, fontSize: 13)),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips(this.list, this.filter, this.recentIds);
  final List<Server> list;
  final ServerFilter filter;
  final List<String> recentIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int count(ServerFilter f) => filterServers(list, '', f, recentIds: recentIds).length;
    String label(ServerFilter f) => switch (f) {
      ServerFilter.all => 'All',
      ServerFilter.online => 'Online',
      ServerFilter.offline => 'Offline',
      ServerFilter.recent => 'Recent',
    };
    // One row that scrolls sideways, never a column of chips.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final f in ServerFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text('${label(f)} ${count(f)}'),
                selected: filter == f,
                labelStyle: TextStyle(
                  color: filter == f ? context.tokens.background : context.tokens.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                onSelected: (_) => ref.read(serverQueryProvider.notifier).setFilter(f),
              ),
            ),
        ],
      ),
    );
  }
}

/// Account balance with a labeled Top up, and a line for low pools.
class _CreditsSummary extends ConsumerWidget {
  const _CreditsSummary({this.dense = false});
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final overview = ref.watch(creditsOverviewProvider).value;
    final credits = overview?.account.credits ?? ref.watch(accountInfoProvider).value?.credits;
    if (credits == null) {
      return AppCard(
        child: Row(
          children: [
            const Expanded(child: Skeleton(width: 160, height: 26)),
            Skeleton(width: 96, height: 40, radius: 14),
          ],
        ),
      );
    }
    final low = overview?.lowPools ?? const [];
    final soonest = low
        .map((p) => p.estimate?.timeLeft)
        .whereType<Duration>()
        .fold<Duration?>(null, (a, b) => a == null || b < a ? b : a);

    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: dense ? 14 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance first; Top up beside it, or below when there is no room,
          // so the balance never shrinks to fit.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dense) Text('Account credits', style: TextStyle(color: t.onSurfaceMuted, fontSize: 14)),
                  CreditsAmount(credits, size: dense ? 22 : 26),
                ],
              ),
              const TopUpButton(),
            ],
          ),
          if (low.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${low.length} ${low.length == 1 ? 'pool' : 'pools'} low'
              '${soonest != null ? ' - ${formatTimeLeft(soonest).replaceFirst('~', '')} left' : ''}',
              style: TextStyle(color: t.warning, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ],
      ),
    );
  }
}

/// One server in the list.
class ServerCard extends StatelessWidget {
  const ServerCard(this.server, {super.key, required this.onTap, this.dense = false, this.selected = false});
  final Server server;
  final VoidCallback onTap;
  final bool dense;
  final bool selected;

  String get _detail {
    final s = server;
    final sw = s.software?.toString();
    if (s.status == ServerStatus.crashed) return 'Crashed - view log';
    final first = switch (s.status) {
      ServerStatus.starting || ServerStatus.loading || ServerStatus.preparing => 'Loading world',
      ServerStatus.online || ServerStatus.offline => '${s.players.count} / ${s.players.max} players',
      _ => s.status.label,
    };
    return sw == null ? first : '$first - $sw';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final title = Text(
      server.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: dense ? 19 : 21, fontWeight: FontWeight.w800, color: t.onSurface),
    );
    final muted = TextStyle(color: t.onSurfaceMuted, fontSize: 16, height: 1.35);
    // Name and status share a line while they fit, then status wraps below.
    final heading = Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [title, StatusLabel(server.status)],
    );

    if (dense) {
      return AppCard(
        selected: selected,
        onTap: onTap,
        semanticLabel: '${server.name}, ${server.status.label}',
        padding: const EdgeInsets.fromLTRB(22, 16, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 2), child: ServerIcon(server, size: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading,
                  const SizedBox(height: 6),
                  Text(_detail, style: muted),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(server.address, style: muted, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(_detail, style: muted, maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    );

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 8), child: ServerIcon(server)),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(padding: const EdgeInsets.only(top: 8), child: heading),
              ),
              ServerMenuButton(server),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, c) {
              final button = actionButtonWidth(context);
              // Side by side while at least 24 characters of address fit
              // beside the button; otherwise the button goes below.
              final charWidth = MediaQuery.textScalerOf(context).scale(16) * 0.5;
              final sideBySide = c.maxWidth - button - 24 >= charWidth * 24;
              if (sideBySide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: details),
                    Padding(padding: const EdgeInsets.only(right: 12), child: PrimaryActionButton(server)),
                  ],
                );
              }
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [details, const SizedBox(height: 12), PrimaryActionButton(server)],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
