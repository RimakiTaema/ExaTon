import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import '../addons/addons.dart';
import '../addons/addons_tab.dart';
import '../config/config_tab.dart';
import '../console/console_view.dart';
import '../console/live_session.dart';
import '../credits/credits_screen.dart';
import '../files/files_tab.dart';
import '../players/players_tab.dart';
import 'access_tab.dart';
import 'calculate_tab.dart';
import 'logs_tab.dart';
import 'overview_tab.dart';
import 'server_actions.dart';
import 'server_icon.dart';
import 'servers.dart';
import 'stats_history.dart';
import '../../ui/app_icons.dart';

enum DetailTab {
  overview('Overview', null),

  /// Share Access details. Only for servers shared with this account.
  access('Access', null),
  console('Console', 'console'),
  players('Players', 'player'),
  files('Files', 'file'),

  /// Mods or plugins from Modrinth. Only for software that takes them.
  addons('Add-ons', 'file'),
  logs('Logs', null),
  config('Config', 'config'),
  pool('Pool', null),

  /// Monthly cost what-ifs. Needs the RAM size, so the same rule as Options.
  calculate('Calculate', 'options');

  const DetailTab(this.label, this.permission);
  final String label;

  /// Keyword matched against the server's `permissions`. Null: always shown.
  final String? permission;
}

/// Server detail with Overview, Access (shared servers), Console, Players, Files, Logs, Config, Pool and Calculate.
/// Tabs the `permissions` list does not allow are hidden.
class ServerDetail extends ConsumerStatefulWidget {
  const ServerDetail({super.key, required this.serverId, this.initialTab = DetailTab.console, this.showBack = false});
  final String serverId;
  final DetailTab initialTab;
  final bool showBack;

  @override
  ConsumerState<ServerDetail> createState() => _ServerDetailState();
}

class _ServerDetailState extends ConsumerState<ServerDetail> with TickerProviderStateMixin {
  TabController? _tabs;
  List<DetailTab> _visible = const [];

  void _syncTabs(List<DetailTab> visible) {
    if (_tabs != null && _sameTabs(visible)) return;
    final current = _tabs == null ? widget.initialTab : _visible[_tabs!.index];
    _tabs?.dispose();
    _visible = visible;
    final i = visible.indexOf(current);
    _tabs = TabController(length: visible.length, vsync: this, initialIndex: i < 0 ? 0 : i);
  }

  bool _sameTabs(List<DetailTab> v) =>
      v.length == _visible.length && Iterable.generate(v.length).every((i) => v[i] == _visible[i]);

  @override
  void dispose() {
    _tabs?.dispose();
    super.dispose();
  }

  void _openLogs() {
    final i = _visible.indexOf(DetailTab.logs);
    if (i >= 0) _tabs?.animateTo(i);
  }

  /// Closes the pushed detail page; the pane on wide windows stays.
  void _onDeleted() {
    if (widget.showBack && mounted) Navigator.of(context).maybePop();
  }

  double _paneWidth = double.infinity;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      _paneWidth = c.maxWidth;
      return _content(context);
    },
  );

  Widget _content(BuildContext context) {
    final server = ref.watch(serverByIdProvider(widget.serverId));
    // Keep the socket open while the detail is on screen.
    ref.watch(liveSessionProvider(widget.serverId));
    // Keep the stats history while any tab is open, not just Overview.
    ref.watch(statsHistoryProvider(widget.serverId).select((_) => 0));
    if (server == null) return const Loading();

    final t = context.tokens;
    final size = WindowSize.of(context);
    // The header follows the pane width: on an 840 px window the detail
    // pane is about 400 px, as narrow as a phone.
    final compact = size == WindowSize.compact || _paneWidth < 640;
    _syncTabs([
      for (final tab in DetailTab.values)
        if (switch (tab) {
          DetailTab.access => server.shared,
          DetailTab.addons => addonTargetOf(server) != null && server.allows(tab.permission!),
          _ => tab.permission == null || server.allows(tab.permission!),
        })
          tab,
    ]);

    final nameStyle = (compact ? Theme.of(context).textTheme.headlineSmall : Theme.of(context).textTheme.headlineMedium)
        ?.copyWith(fontWeight: FontWeight.w800);
    final name = Semantics(
      header: true,
      child: Text(server.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: nameStyle),
    );
    final back = widget.showBack
        ? IconButton(
            tooltip: 'Back to servers',
            icon: const Icon(AppIcons.back),
            onPressed: () => Navigator.of(context).maybePop(),
          )
        : null;

    // Phones: two rows, back and name, then status and actions. When the
    // action button would squeeze the status (large text), it moves into
    // the overflow menu, which has Start and Stop too.
    final Widget header = compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ?back,
                  const SizedBox(width: 4),
                  ServerIcon(server, size: 34),
                  const SizedBox(width: 14),
                  Expanded(child: name),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: EdgeInsets.only(left: widget.showBack ? 52 : 4),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final showButton = c.maxWidth - actionButtonWidth(context) - 48 >= 120;
                    return Row(
                      children: [
                        Expanded(
                          child: StatusLabel(server.status, suffix: '${server.players.count} / ${server.players.max}'),
                        ),
                        if (showButton) PrimaryActionButton(server),
                        ServerMenuButton(server, onViewLog: _openLogs, onDeleted: _onDeleted),
                      ],
                    );
                  },
                ),
              ),
            ],
          )
        : Row(
            children: [
              ?back,
              ServerIcon(server, size: 52),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    name,
                    Text(
                      '${server.address} - ${server.players.count} / ${server.players.max} players',
                      style: TextStyle(color: t.onSurfaceMuted, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (server.status == ServerStatus.online) _RestartButton(server),
                  PrimaryActionButton(server),
                  ServerMenuButton(server, onViewLog: _openLogs, onDeleted: _onDeleted),
                ],
              ),
            ],
          );

    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 8 : 28, compact ? 8 : 24, compact ? 8 : 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 12),
          _FadingTabBar(
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabs: [for (final tab in _visible) Tab(text: tab.label)],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 0),
              child: TabBarView(
                controller: _tabs,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final tab in _visible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: switch (tab) {
                        DetailTab.overview => OverviewTab(server: server, onViewLog: _openLogs, onDeleted: _onDeleted),
                        DetailTab.access => AccessTab(server: server),
                        DetailTab.console => ConsoleView(serverId: server.id, sidePanel: size == WindowSize.expanded),
                        DetailTab.players => PlayersTab(server: server),
                        DetailTab.files => FilesTab(server: server),
                        DetailTab.addons => AddonsTab(server: server),
                        DetailTab.logs => LogsTab(server: server),
                        DetailTab.config => ConfigTab(server: server),
                        DetailTab.pool => ServerPoolTab(server: server),
                        DetailTab.calculate => CalculateTab(server: server),
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestartButton extends ConsumerWidget {
  const _RestartButton(this.server);
  final Server server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(serverActionsProvider.select((m) => m.containsKey(server.id)));
    return OutlinedButton(
      onPressed: pending ? null : () => runAction(context, ref, server, ServerAction.restart),
      child: const Text('Restart'),
    );
  }
}

/// Full-screen detail for phones and medium windows.
class ServerDetailPage extends StatelessWidget {
  const ServerDetailPage({super.key, required this.serverId, this.initialTab = DetailTab.console});
  final String serverId;
  final DetailTab initialTab;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ServerDetail(serverId: serverId, initialTab: initialTab, showBack: true),
    ),
  );
}

/// Fades the right edge of a scrollable tab bar while more tabs are off
/// screen, so it is clear the row continues. The selected tab scrolls into
/// view on its own (TabBar does this).
class _FadingTabBar extends StatefulWidget {
  const _FadingTabBar({required this.child});
  final Widget child;

  @override
  State<_FadingTabBar> createState() => _FadingTabBarState();
}

class _FadingTabBarState extends State<_FadingTabBar> {
  bool _more = false;
  bool _before = false;

  bool _onMetrics(ScrollMetrics m) {
    final more = m.extentAfter > 1, before = m.extentBefore > 1;
    if (more != _more || before != _before) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _more = more;
            _before = before;
          });
        }
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => _onMetrics(n.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) => _onMetrics(n.metrics),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => LinearGradient(
            colors: [
              Color(_before ? 0x00000000 : 0xFF000000),
              const Color(0xFF000000),
              const Color(0xFF000000),
              Color(_more ? 0x00000000 : 0xFF000000),
            ],
            stops: [0, r.width == 0 ? 0 : 32 / r.width, r.width == 0 ? 1 : 1 - 40 / r.width, 1],
          ).createShader(r),
          child: widget.child,
        ),
      ),
    );
  }
}
