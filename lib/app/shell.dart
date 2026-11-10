import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exaroton/models.dart';
import '../features/accounts/account_chip.dart';
import '../features/accounts/accounts.dart';
import '../features/accounts/add_account_screen.dart';
import '../features/accounts/migration.dart';
import '../features/accounts/migration_screen.dart';
import '../features/credits/alerts.dart';
import '../features/credits/credits.dart';
import '../features/credits/credits_screen.dart';
import '../features/servers/recent_servers.dart';
import '../features/servers/server_detail.dart';
import '../features/servers/server_icon.dart';
import '../features/servers/servers.dart';
import '../features/servers/servers_screen.dart';
import '../features/settings/settings.dart';
import '../features/settings/settings_screen.dart';
import '../ui/components.dart';
import '../ui/motion.dart';
import '../ui/tokens.dart';
import '../ui/app_icons.dart';

enum _Dest { servers, console, credits, settings }

/// Phones: bottom bar with Servers, Console, Credits and Settings.
/// Wide windows: left rail, scrollable server list and a detail pane.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  _Dest _dest = _Dest.servers;

  void _focusSearch() {
    setState(() => _dest = _Dest.servers);
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(searchFocusProvider).requestFocus());
  }

  void _open(Server s, WindowSize size) {
    ref.read(selectedServerProvider.notifier).select(s.id);
    if (size != WindowSize.expanded) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServerDetailPage(serverId: s.id)));
    }
  }

  /// 1.5 logins being offered. Held here, not read live, so the screen stays
  /// up while imports add accounts.
  List<LegacyAccount>? _migration;
  bool _migrationHandled = false;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final prompt = _migrationHandled ? const AsyncData(<LegacyAccount>[]) : ref.watch(migrationPromptProvider);
    if (!_migrationHandled && _migration == null && (prompt.value?.isNotEmpty ?? false)) {
      _migration = prompt.value;
    }

    final Widget page;
    if (_migration != null) {
      page = MigrationScreen(
        key: const ValueKey('migration'),
        accounts: _migration!,
        onDone: () => setState(() {
          _migration = null;
          _migrationHandled = true;
        }),
      );
    } else {
      page = switch (accounts) {
        // Wait for the 1.5 check before showing sign-in, so it does not flash.
        AsyncData(:final value) when value.accounts.isEmpty && prompt.isLoading => const Scaffold(
          key: ValueKey('loading'),
          body: Loading(),
        ),
        AsyncData(:final value) when value.accounts.isEmpty => const AddAccountScreen(key: ValueKey('signin')),
        AsyncData() => KeyedSubtree(key: const ValueKey('app'), child: _buildApp(context)),
        AsyncError(:final error) => Scaffold(
          key: const ValueKey('error'),
          body: ErrorPanel(error, onRetry: () => ref.invalidate(accountsProvider)),
        ),
        _ => const Scaffold(key: ValueKey('loading'), body: Loading()),
      };
    }
    return FadeThrough(child: page);
  }

  Widget _buildApp(BuildContext context) {
    ref.watch(creditsTickerProvider);
    ref.listen(creditsOverviewProvider, (_, next) {
      final o = next.value;
      final id = ref.read(activeAccountProvider)?.id;
      if (o != null && id != null) {
        CreditAlerts.instance.evaluate(o, ref.read(settingsProvider), ref.read(databaseProvider), id);
      }
    });

    final size = WindowSize.of(context);
    final t = context.tokens;
    final selected = ref.watch(selectedServerProvider);

    // Expanded: keep a server selected so the detail pane is never blank.
    if (size == WindowSize.expanded && selected == null) {
      final first = ref.watch(serversProvider).value?.firstOrNull;
      if (first != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => ref.read(selectedServerProvider.notifier).select(first.id, record: false),
        );
      }
    }

    // Only the current destination is built, so leaving the console closes
    // its socket.
    final Widget body = switch (_dest) {
      _Dest.servers when size == WindowSize.expanded => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: WindowSize.listPaneWidth(MediaQuery.sizeOf(context).width),
            child: ServersScreen(dense: true, onOpen: (s) => _open(s, size)),
          ),
          VerticalDivider(width: 1, color: t.outline),
          Expanded(
            child: selected == null
                ? Center(
                    child: Text('Select a server', style: TextStyle(color: t.onSurfaceMuted)),
                  )
                : ServerDetail(key: ValueKey(selected), serverId: selected),
          ),
        ],
      ),
      // Medium: one readable column rather than cards stretched edge to edge.
      _Dest.servers => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ServersScreen(onOpen: (s) => _open(s, size)),
        ),
      ),
      _Dest.console => _ConsoleDestination(onPick: (s) => ref.read(selectedServerProvider.notifier).select(s.id)),
      _Dest.credits => const CreditsScreen(),
      _Dest.settings => const SettingsScreen(),
    };

    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.keyK, control: true): _focusSearch,
      const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _focusSearch,
    };

    if (size == WindowSize.compact) {
      return CallbackShortcuts(
        bindings: shortcuts,
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: FadeThrough(
              child: KeyedSubtree(key: ValueKey(_dest), child: body),
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.outline)),
            ),
            child: NavigationBar(
              selectedIndex: _dest.index,
              // The last button is the account: it opens the switcher and
              // leaves the current page where it is.
              onDestinationSelected: (i) =>
                  i == _Dest.values.length ? showAccountSheet(context, ref) : setState(() => _dest = _Dest.values[i]),
              destinations: [
                const NavigationDestination(
                  icon: Icon(AppIcons.servers),
                  selectedIcon: Icon(AppIcons.serversSelected),
                  label: 'Servers',
                ),
                const NavigationDestination(
                  icon: Icon(AppIcons.console),
                  selectedIcon: Icon(AppIcons.consoleSelected),
                  label: 'Console',
                ),
                const NavigationDestination(
                  icon: Icon(AppIcons.credits),
                  selectedIcon: Icon(AppIcons.creditsSelected),
                  label: 'Credits',
                ),
                const NavigationDestination(
                  icon: Icon(AppIcons.settings),
                  selectedIcon: Icon(AppIcons.settingsSelected),
                  label: 'Settings',
                ),
                NavigationDestination(
                  icon: Avatar(ref.watch(activeAccountProvider)?.name ?? '', size: 26),
                  label: 'Account',
                  tooltip: 'Account: ${ref.watch(activeAccountProvider)?.name ?? ''}. Switch account',
                ),
              ],
            ),
          ),
        ),
      );
    }

    // The rail has no Console: on wide windows it lives in the detail pane.
    // Top to bottom: logo, Servers and Credits, a separator, recent servers,
    // a separator, then Account and Settings at the bottom.
    const railDests = [_Dest.servers, _Dest.credits];
    final railDest = _dest == _Dest.console ? _Dest.servers : _dest;
    final railIndex = railDests.indexOf(railDest);
    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NavigationRail(
                  selectedIndex: railIndex < 0 ? null : railIndex,
                  onDestinationSelected: (i) => setState(() => _dest = railDests[i]),
                  minWidth: 96,
                  groupAlignment: -1,
                  // Fills the height, so the tail can pin its last buttons
                  // to the bottom.
                  mainAxisAlignment: MainAxisAlignment.start,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 16),
                    child: Semantics(
                      image: true,
                      label: 'ExaTon',
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 52,
                        height: 52,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  trailing: Expanded(
                    child: _RailTail(
                      settingsSelected: railDest == _Dest.settings,
                      onSettings: () => setState(() => _dest = _Dest.settings),
                      onOpen: (s) {
                        setState(() => _dest = _Dest.servers);
                        _open(s, size);
                      },
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(AppIcons.servers),
                      selectedIcon: Icon(AppIcons.serversSelected),
                      label: Text('Servers'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(AppIcons.credits),
                      selectedIcon: Icon(AppIcons.creditsSelected),
                      label: Text('Credits'),
                    ),
                  ],
                ),
                VerticalDivider(width: 1, color: t.outline),
                Expanded(
                  child: FadeThrough(
                    child: KeyedSubtree(
                      key: ValueKey(railDest),
                      child: _dest == _Dest.servers
                          ? body
                          : Center(
                              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: body),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Everything in the rail under Servers and Credits: a separator, the
/// recent servers (scrolling when they do not fit), another separator, and
/// Account and Settings at the bottom.
class _RailTail extends ConsumerWidget {
  const _RailTail({required this.settingsSelected, required this.onSettings, required this.onOpen});
  final bool settingsSelected;
  final VoidCallback onSettings;
  final void Function(Server) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final account = ref.watch(activeAccountProvider);
    final separator = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 48,
        height: 3,
        decoration: BoxDecoration(color: t.outline, borderRadius: BorderRadius.circular(2)),
      ),
    );
    return Column(
      children: [
        separator,
        Expanded(child: _RailRecent(onOpen: onOpen)),
        separator,
        AccountMenu(
          position: PopupMenuPosition.over,
          child: _RailItem(icon: Avatar(account?.name ?? '', size: 28), label: 'Account'),
        ),
        _RailItem(
          icon: Icon(
            settingsSelected ? AppIcons.settingsSelected : AppIcons.settings,
            color: settingsSelected ? t.primary : t.onSurfaceMuted,
          ),
          label: 'Settings',
          selected: settingsSelected,
          onTap: onSettings,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// A button that looks like a rail destination. With no [onTap] it only
/// draws, for use inside a menu button.
class _RailItem extends StatelessWidget {
  const _RailItem({required this.icon, required this.label, this.selected = false, this.onTap});
  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final rail = Theme.of(context).navigationRailTheme;
    final style = (selected ? rail.selectedLabelTextStyle : rail.unselectedLabelTextStyle) ?? const TextStyle();
    final body = SizedBox(
      width: 96,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: selected ? t.surface : null, borderRadius: BorderRadius.circular(16)),
              child: icon,
            ),
            const SizedBox(height: 4),
            Text(label, style: style.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
    if (onTap == null) return body;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: body),
    );
  }
}

/// "Recent" section of the rail: the servers opened last, other than the
/// one on screen, newest first.
class _RailRecent extends ConsumerWidget {
  const _RailRecent({required this.onOpen});
  final void Function(Server) onOpen;

  static const _max = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final selected = ref.watch(selectedServerProvider);
    final recent = [
      for (final r in ref.watch(recentServersProvider))
        if (r.id != selected) ?ref.watch(serverByIdProvider(r.id)),
    ].take(_max).toList();
    if (recent.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            label: 'Recent servers',
            excludeSemantics: true,
            child: Text(
              'Recent',
              style: TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          for (final s in recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tooltip(
                message: '${s.name} - ${s.status.label}',
                child: Semantics(
                  button: true,
                  label: 'Open ${s.name}, ${s.status.label}',
                  excludeSemantics: true,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => onOpen(s),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ServerIcon(s, size: 40, showPlatform: false),
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: statusColor(context, s.status),
                                shape: BoxShape.circle,
                                border: Border.all(color: t.background, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Phone Console tab: the selected server's console, or a picker.
class _ConsoleDestination extends ConsumerWidget {
  const _ConsoleDestination({required this.onPick});
  final void Function(Server) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final selected = ref.watch(selectedServerProvider);
    if (selected != null && ref.watch(serverByIdProvider(selected)) != null) {
      return ServerDetail(key: ValueKey('console-$selected'), serverId: selected, initialTab: DetailTab.console);
    }
    final servers = ref.watch(serversProvider).value ?? const [];
    return ListView(
      padding: const EdgeInsets.all(gutter),
      children: [
        Text('Console', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text('Pick a server to open its console.', style: TextStyle(color: t.onSurfaceMuted)),
        const SizedBox(height: 16),
        for (final s in servers) ...[ServerCard(s, dense: true, onTap: () => onPick(s)), const SizedBox(height: 10)],
      ],
    );
  }
}
