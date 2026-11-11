import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/console/ansi.dart';
import '../../core/console/complete.dart';
import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../core/exaroton/websocket.dart';
import '../../ui/components.dart';
import '../../ui/motion.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../settings/settings.dart';
import 'console_side_panel.dart';
import 'live_session.dart';
import '../../ui/app_icons.dart';

const _mono = TextStyle(fontFamily: monoFont, fontSize: 14.5, height: 1.45);

/// The players, pool and activity panel shows beside the console from this
/// width.
const sidePanelMinWidth = 820.0;

/// Below this many lines the log is bottom-aligned.
const shortLogLines = 300;

class ConsoleView extends ConsumerStatefulWidget {
  const ConsoleView({super.key, required this.serverId, this.sidePanel = false});
  final String serverId;
  final bool sidePanel;

  @override
  ConsumerState<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends ConsumerState<ConsoleView> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  final _inputFocus = FocusNode();
  String _query = '';
  bool _following = true;
  int _historyIndex = -1;
  LiveSession? _listening;

  @override
  void dispose() {
    _listening?.linesVersion.removeListener(_onLines);
    _scroll.dispose();
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _bind(LiveSession? s) {
    if (identical(s, _listening)) return;
    _listening?.linesVersion.removeListener(_onLines);
    _listening = s;
    s?.linesVersion.addListener(_onLines);
  }

  void _onLines() {
    if (_following) _jumpToEnd();
  }

  /// New lines jump (cheap at high log rates); a tap on "Jump to latest"
  /// glides there.
  void _jumpToEnd({bool animate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      final d = Motion.of(context, Motion.long);
      if (animate && d > Duration.zero) {
        _scroll.animateTo(end, duration: d, curve: Motion.emphasized);
      } else {
        _scroll.jumpTo(end);
      }
    });
  }

  bool _onScroll(ScrollNotification n) {
    // Auto-scroll turns off when the user scrolls up, back on at the bottom.
    if (n is ScrollUpdateNotification && n.dragDetails != null) {
      final atEnd = n.metrics.pixels >= n.metrics.maxScrollExtent - 24;
      if (_following != atEnd) setState(() => _following = atEnd);
    }
    return false;
  }

  Future<void> _send(LiveSession s, [String? text]) async {
    final cmd = (text ?? _input.text).trim();
    if (cmd.isEmpty || s.commandInFlight) return;
    try {
      await s.sendCommand(cmd);
      if (text == null) _input.clear();
      _historyIndex = -1;
      setState(() => _following = true);
      _jumpToEnd();
    } on ExarotonException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  void _complete(String name) {
    final v = completeWith(_input.text, name);
    _input.value = TextEditingValue(
      text: v,
      selection: TextSelection.collapsed(offset: v.length),
    );
    _inputFocus.requestFocus();
  }

  Future<void> _addQuick(String cmd) async {
    final c = cmd.trim();
    if (c.isEmpty) return;
    await ref
        .read(settingsProvider.notifier)
        .update((x) => x.copyWith(quickCommands: [...x.quickCommands.where((q) => q != c), c]));
    if (mounted) showMessage(context, 'Added "$c" to quick commands');
  }

  Future<void> _removeQuick(String cmd) async {
    final ok = await confirm(
      context,
      title: 'Remove "$cmd"?',
      body: 'It is removed from the quick commands on every server.',
      action: 'Remove',
    );
    if (!ok) return;
    await ref
        .read(settingsProvider.notifier)
        .update((x) => x.copyWith(quickCommands: x.quickCommands.where((q) => q != cmd).toList()));
  }

  KeyEventResult _onKey(LiveSession s, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    // Tab completes a player name, the first match.
    if (e.logicalKey == LogicalKeyboardKey.tab) {
      final m = playerCompletions(_input.text, s.server.players.list);
      if (m.isEmpty) return KeyEventResult.ignored;
      _complete(m.first);
      return KeyEventResult.handled;
    }
    final h = s.history;
    if (e.logicalKey == LogicalKeyboardKey.arrowUp && h.isNotEmpty) {
      _historyIndex = (_historyIndex + 1).clamp(0, h.length - 1);
    } else if (e.logicalKey == LogicalKeyboardKey.arrowDown && _historyIndex >= 0) {
      _historyIndex--;
    } else {
      return KeyEventResult.ignored;
    }
    final v = _historyIndex < 0 ? '' : h[_historyIndex];
    _input.value = TextEditingValue(
      text: v,
      selection: TextSelection.collapsed(offset: v.length),
    );
    return KeyEventResult.handled;
  }

  Future<void> _pickHistory(LiveSession s) async {
    final cmd = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => s.history.isEmpty
          ? const SizedBox(height: 160, child: Center(child: Text('No commands yet')))
          : ListView(
              shrinkWrap: true,
              children: [
                for (final h in s.history)
                  ListTile(
                    title: Text(h, style: _mono),
                    onTap: () => Navigator.pop(c, h),
                    trailing: IconButton(
                      tooltip: 'Add to quick commands',
                      icon: const Icon(AppIcons.add),
                      onPressed: () {
                        Navigator.pop(c);
                        _addQuick(h);
                      },
                    ),
                  ),
              ],
            ),
    );
    if (cmd != null) {
      _input.text = cmd;
      _inputFocus.requestFocus();
    }
  }

  List<int> _visible(LiveSession s) {
    final q = _query.toLowerCase();
    final out = <int>[];
    for (var i = 0; i < s.lines.length; i++) {
      if (q.isEmpty || s.lines[i].plain.toLowerCase().contains(q)) out.add(i);
    }
    return out;
  }

  Future<void> _copy(LiveSession s) async {
    final text = _visible(s).map((i) => s.lines[i].plain).join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showMessage(context, 'Copied ${_visible(s).length} lines');
  }

  Future<void> _share(LiveSession s) async {
    try {
      final log = await s.shareLog();
      await launchUrl(Uri.parse(log.url), mode: LaunchMode.externalApplication);
    } on ExarotonException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(liveSessionProvider(widget.serverId));
    _bind(s);
    if (s == null) return const Loading();
    // Sized by the space the console gets, not the window: next to the
    // server list on an 840 px window the pane is narrow.
    return LayoutBuilder(
      builder: (context, c) {
        final side = widget.sidePanel && c.maxWidth >= sidePanelMinWidth;
        final compact = (side ? c.maxWidth - 320 : c.maxWidth) < 560;
        return _layout(context, s, compact: compact, side: side);
      },
    );
  }

  Widget _layout(BuildContext context, LiveSession s, {required bool compact, required bool side}) {
    final t = context.tokens;
    final console = ListenableBuilder(
      listenable: s,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar: search, copy, clear, follow.
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search logs',
                    prefixIcon: const Icon(AppIcons.search),
                    suffixText: _query.isEmpty ? null : '${_visible(s).length} matches',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              LabeledIconButton(icon: AppIcons.copy, label: 'Copy lines', onPressed: () => _copy(s)),
              const SizedBox(width: 10),
              LabeledIconButton(icon: AppIcons.delete, label: 'Clear console', onPressed: s.clear),
              const SizedBox(width: 10),
              if (compact)
                LabeledIconButton(
                  icon: AppIcons.follow,
                  label: _following ? 'Following new lines' : 'Follow new lines',
                  selected: _following,
                  onPressed: () {
                    setState(() => _following = !_following);
                    if (_following) _jumpToEnd();
                  },
                )
              else
                _FollowButton(
                  following: _following,
                  onPressed: () {
                    setState(() => _following = !_following);
                    if (_following) _jumpToEnd();
                  },
                ),
              if (!compact) ...[
                const SizedBox(width: 10),
                LabeledIconButton(icon: AppIcons.share, label: 'Share log on mclo.gs', onPressed: () => _share(s)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (s.socketState == SocketState.reconnecting)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: WarningBanner('Reconnecting to the console...')),
          if (s.server.status != ServerStatus.online && s.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InfoNote('The console streams while the server is online. Status: ${s.server.status.label}.'),
            ),
          // Log.
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: t.consoleBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: t.outline),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: s.linesVersion,
                    builder: (context, _, _) {
                      final visible = _visible(s);
                      return NotificationListener<ScrollNotification>(
                        onNotification: _onScroll,
                        child: SelectionArea(
                          // A short log sits at the bottom, like a terminal.
                          // Past a few hundred lines it always fills the
                          // panel, so the list goes back to lazy building.
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ListView.builder(
                              controller: _scroll,
                              shrinkWrap: visible.length < shortLogLines,
                              padding: const EdgeInsets.all(16),
                              itemCount: visible.length,
                              itemBuilder: (context, i) {
                                final idx = visible[i];
                                // Stable key per line, so evicting old lines keeps rows.
                                return _LineView(
                                  key: ValueKey(s.lines.sequenceOf(idx)),
                                  line: s.lines[idx],
                                  query: _query,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Slides up when the user scrolls away, drops out on follow.
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      ignoring: _following,
                      child: AnimatedSlide(
                        offset: _following ? const Offset(0, 1.6) : Offset.zero,
                        duration: Motion.of(context, Motion.medium),
                        curve: Motion.emphasized,
                        child: AnimatedOpacity(
                          opacity: _following ? 0 : 1,
                          duration: Motion.of(context, Motion.short),
                          child: Center(
                            child: ActionChip(
                              avatar: Icon(AppIcons.follow, color: t.onPrimary, size: 18),
                              backgroundColor: t.primary,
                              label: Text(
                                'Jump to latest',
                                style: TextStyle(color: t.onPrimary, fontWeight: FontWeight.w700),
                              ),
                              onPressed: () {
                                setState(() => _following = true);
                                _jumpToEnd(animate: true);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Player names that complete the word being typed, else quick
          // commands (long-press one to remove it).
          ValueListenableBuilder(
            valueListenable: _input,
            builder: (context, v, _) {
              final names = playerCompletions(v.text, s.server.players.list);
              final quick = ref.watch(settingsProvider.select((x) => x.quickCommands));
              final typed = v.text.trim();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: names.isNotEmpty
                      ? [
                          for (final n in names)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ActionChip(
                                avatar: const Icon(AppIcons.addPlayer, size: 18),
                                label: Text(n, style: _mono.copyWith(fontWeight: FontWeight.w700)),
                                onPressed: () => _complete(n),
                              ),
                            ),
                        ]
                      : [
                          // First, so it is in view while typing on a phone.
                          if (typed.isNotEmpty && !quick.contains(typed))
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ActionChip(
                                avatar: const Icon(AppIcons.add, size: 18),
                                label: const Text('Save as quick command'),
                                onPressed: () => _addQuick(typed),
                              ),
                            ),
                          for (final c in quick)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onLongPress: () => _removeQuick(c),
                                child: ActionChip(
                                  label: Text(c, style: _mono.copyWith(fontWeight: FontWeight.w700)),
                                  onPressed: s.commandInFlight ? null : () => _send(s, c),
                                ),
                              ),
                            ),
                        ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          // Input.
          Row(
            children: [
              LabeledIconButton(icon: AppIcons.history, label: 'Command history', onPressed: () => _pickHistory(s)),
              const SizedBox(width: 10),
              Expanded(
                child: Focus(
                  onKeyEvent: (_, e) => _onKey(s, e),
                  child: TextField(
                    controller: _input,
                    focusNode: _inputFocus,
                    style: _mono,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      _send(s);
                      _inputFocus.requestFocus();
                    },
                    decoration: InputDecoration(
                      hintText: compact ? 'Type a command' : 'Type a command - up arrow for history',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder(
                valueListenable: _input,
                builder: (_, v, _) {
                  final enabled = v.text.trim().isNotEmpty && !s.commandInFlight;
                  return compact
                      ? Semantics(
                          label: 'Send command',
                          button: true,
                          excludeSemantics: true,
                          child: FilledButton(
                            onPressed: enabled ? () => _send(s) : null,
                            style: FilledButton.styleFrom(minimumSize: const Size(56, 52), padding: EdgeInsets.zero),
                            child: const Icon(AppIcons.send),
                          ),
                        )
                      : FilledButton(
                          onPressed: enabled ? () => _send(s) : null,
                          style: FilledButton.styleFrom(minimumSize: const Size(96, 52)),
                          child: const Text('Send'),
                        );
                },
              ),
            ],
          ),
        ],
      ),
    );

    if (!side) return console;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: console),
        const SizedBox(width: 20),
        SizedBox(width: 300, child: ConsoleSidePanel(session: s)),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.following, required this.onPressed});
  final bool following;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: following ? t.onSelectedFill : t.onSurface,
        backgroundColor: following ? t.selectedFill : t.surface,
        side: BorderSide(color: following ? t.primary : t.outlineStrong),
      ),
      icon: const Icon(AppIcons.follow, size: 20),
      label: Text(following ? 'Following' : 'Follow'),
    );
  }
}

class _LineView extends StatelessWidget {
  const _LineView({super.key, required this.line, required this.query});
  final ConsoleLine line;
  final String query;

  Color? _color(AppTokens t, AnsiColor? c) => switch (c) {
    null => null,
    AnsiColor.red || AnsiColor.brightRed => t.error,
    AnsiColor.yellow || AnsiColor.brightYellow => t.warning,
    AnsiColor.green || AnsiColor.brightGreen => t.success,
    AnsiColor.blue || AnsiColor.brightBlue || AnsiColor.cyan || AnsiColor.brightCyan => t.primary,
    AnsiColor.magenta || AnsiColor.brightMagenta => t.primary,
    AnsiColor.black || AnsiColor.brightBlack => t.onSurfaceMuted,
    AnsiColor.white || AnsiColor.brightWhite => t.onSurface,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Color base = t.onSurface;
    if (line.isCommand) {
      base = t.primary;
    } else if (line.spans.every((s) => s.color == null)) {
      // Uncoloured logs: tint by level so warnings and errors stand out.
      if (line.plain.contains('WARN]') || line.plain.contains('/WARN]')) base = t.warning;
      if (line.plain.contains('ERROR]') || line.plain.contains('/ERROR]')) base = t.error;
    }
    final spans = <InlineSpan>[];
    for (final s in line.spans) {
      final style = TextStyle(
        color: _color(t, s.color) ?? base,
        fontWeight: s.bold ? FontWeight.w700 : null,
        fontStyle: s.italic ? FontStyle.italic : null,
        decoration: s.underline ? TextDecoration.underline : null,
      );
      spans.addAll(_highlight(s.text, style, t));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text.rich(
        TextSpan(
          style: _mono.copyWith(color: base),
          children: spans,
        ),
      ),
    );
  }

  List<InlineSpan> _highlight(String text, TextStyle style, AppTokens t) {
    if (query.isEmpty) return [TextSpan(text: text, style: style)];
    final out = <InlineSpan>[];
    final lower = text.toLowerCase(), q = query.toLowerCase();
    var i = 0;
    while (true) {
      final j = lower.indexOf(q, i);
      if (j < 0) {
        out.add(TextSpan(text: text.substring(i), style: style));
        break;
      }
      if (j > i) out.add(TextSpan(text: text.substring(i, j), style: style));
      out.add(
        TextSpan(
          text: text.substring(j, j + q.length),
          style: style.copyWith(backgroundColor: t.warning.withValues(alpha: 0.35), color: t.onSurface),
        ),
      );
      i = j + q.length;
    }
    return out;
  }
}
