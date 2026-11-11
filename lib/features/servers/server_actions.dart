import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/motion.dart';
import '../../ui/toast.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import 'logs_tab.dart';
import 'recent_servers.dart';
import 'server_form.dart';
import 'servers.dart';
import '../../ui/app_icons.dart';

Future<void> runAction(
  BuildContext context,
  WidgetRef ref,
  Server s,
  ServerAction a, {
  bool useOwnCredits = false,
}) async {
  // Stop and Restart disconnect players, so ask when anyone is online.
  // With nobody online they run at once. Start never asks.
  final n = s.players.count;
  if ((a == ServerAction.stop || a == ServerAction.restart) && n > 0) {
    final stop = a == ServerAction.stop;
    final ok = await confirm(
      context,
      title: '${stop ? 'Stop' : 'Restart'} ${s.name}?',
      body: '$n ${n == 1 ? 'player is' : 'players are'} online and will be disconnected.',
      action: stop ? 'Stop server' : 'Restart server',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
  }
  try {
    final msg = await ref.read(serverActionsProvider.notifier).run(s, a, useOwnCredits: useOwnCredits);
    if (msg != null && context.mounted) showMessage(context, msg);
  } on ExarotonException catch (e) {
    if (context.mounted) showMessage(context, e.message, tone: Tone.error);
  }
}

/// Deletes a server after a confirmation. Owner only. A server that is not
/// offline or crashed cannot be deleted, so the user is told to stop it
/// first. [onDeleted] runs right after the API accepts, before the list
/// reloads, so a detail page can close itself. Returns whether it was deleted.
Future<bool> deleteServerFlow(BuildContext context, WidgetRef ref, Server s, {VoidCallback? onDeleted}) async {
  final client = ref.read(clientProvider);
  if (client == null || !s.isOwner) return false;
  final toaster = Toaster.of(context);
  void say(String text, {Tone? tone}) => toaster?.show(text, tone: tone);

  final g = s.status.group;
  if (g != StatusGroup.offline && g != StatusGroup.crashed) {
    final stop = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Stop ${s.name} first'),
        content: Text(
          g == StatusGroup.online
              ? 'A server can only be deleted while it is offline. Stop it, then delete it.'
              : 'A server can only be deleted while it is offline. It is ${s.status.label.toLowerCase()} now; '
                    'wait until it is offline.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          if (g == StatusGroup.online)
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Stop server')),
        ],
      ),
    );
    if (stop == true && context.mounted) await runAction(context, ref, s, ServerAction.stop);
    return false;
  }

  final ok = await confirm(
    context,
    title: 'Delete ${s.name}?',
    body:
        'All files of this server are permanently deleted, including worlds, plugins, mods and settings. '
        'This cannot be undone.',
    action: 'Delete server',
    destructive: true,
  );
  if (!ok) return false;
  try {
    await client.deleteServer(s.id);
  } on ExarotonException catch (e) {
    say(e.message, tone: Tone.error);
    return false;
  }
  onDeleted?.call();
  if (ref.read(selectedServerProvider) == s.id) ref.read(selectedServerProvider.notifier).select(null);
  await ref.read(recentServersControllerProvider).forget(s.id);
  await ref.read(serversProvider.notifier).refresh();
  say('${s.name} deleted', tone: Tone.success);
  return true;
}

/// Picks software, shows what installing it does, and installs it. A
/// reinstall, which deletes every file, needs a second confirmation.
Future<void> changeSoftwareFlow(BuildContext context, WidgetRef ref, Server s) async {
  final choice = await pickSoftware(context, currentId: s.software?.id);
  if (choice != null && choice.custom && context.mounted) {
    await showCustomSoftwareDialog(context, serverName: s.name);
    return;
  }
  final software = choice?.software;
  if (software == null || !context.mounted) return;
  final details = await showDialog<SoftwareDetails>(
    context: context,
    builder: (_) => SoftwareDetailsDialog(server: s, software: software),
  );
  if (details == null || !context.mounted) return;
  if (details.reinstall) {
    final ok = await confirm(
      context,
      title: 'Reinstall ${s.name}?',
      body:
          'Installing $software deletes all server files, including worlds, plugins, mods and settings. '
          'This cannot be undone.',
      action: 'Delete files and install',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
  }
  final client = ref.read(clientProvider);
  if (client == null) return;
  try {
    await client.installSoftware(s.id, software.id, reinstall: details.reinstall);
    if (context.mounted) showMessage(context, 'Installing $software. The server status shows the progress.');
    await ref.read(serversProvider.notifier).refresh();
  } on ExarotonException catch (e) {
    if (context.mounted) showMessage(context, e.message, tone: Tone.error);
  }
}

/// Start, Stop or a disabled busy button, per the status groups:
/// Online → Stop; Offline and Crashed → Start; Busy → disabled with spinner.
class PrimaryActionButton extends ConsumerWidget {
  const PrimaryActionButton(this.server, {super.key});
  final Server server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(serverActionsProvider.select((m) => m[server.id]));
    final group = server.status.group;
    final key = pending != null || group == StatusGroup.busy ? 'busy' : group.name;
    // The button morphs between Start, Stop and the busy spinner.
    return SizedBox(
      width: actionButtonWidth(context),
      child: StateSwitcher(
        alignment: Alignment.centerRight,
        child: SizedBox(key: ValueKey(key), width: double.infinity, child: _button(context, ref, pending, group)),
      ),
    );
  }

  Widget _button(BuildContext context, WidgetRef ref, PendingAction? pending, StatusGroup group) {
    final t = context.tokens;
    const pad = EdgeInsets.symmetric(horizontal: 10, vertical: 12);

    if (pending != null || group == StatusGroup.busy) {
      final label = pending != null && group != StatusGroup.busy
          ? switch (pending.action) {
              ServerAction.start => 'Starting',
              ServerAction.stop => 'Stopping',
              ServerAction.restart => 'Restarting',
            }
          : server.status.label;
      return Semantics(
        label: '$label, please wait',
        excludeSemantics: true,
        child: OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            padding: pad,
            disabledForegroundColor: t.onSurfaceMuted,
            backgroundColor: t.background,
            side: BorderSide(color: t.outline),
          ),
          child: OneLine(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: t.onSurfaceMuted),
                ),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
          ),
        ),
      );
    }

    if (group == StatusGroup.online) {
      return OutlinedButton(
        onPressed: () => runAction(context, ref, server, ServerAction.stop),
        style: OutlinedButton.styleFrom(
          padding: pad,
          foregroundColor: t.error,
          side: BorderSide(color: t.error),
        ),
        child: OneLine(
          alignment: Alignment.center,
          child: Text('Stop', semanticsLabel: 'Stop ${server.name}'),
        ),
      );
    }

    // Shared servers offer "Start with my credits" in the card's menu, so
    // this button keeps the same width in every state.
    return FilledButton(
      onPressed: () => runAction(context, ref, server, ServerAction.start),
      style: FilledButton.styleFrom(padding: pad),
      child: OneLine(
        alignment: Alignment.center,
        child: Text('Start', semanticsLabel: 'Start ${server.name}'),
      ),
    );
  }
}

/// One width for Start, Stop and busy, so nothing beside the button moves
/// when the status changes. Grows with the text size.
double actionButtonWidth(BuildContext context) =>
    104 * (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(1.0, 2.0);

/// Overflow menu with every action the status allows.
class ServerMenuButton extends ConsumerWidget {
  const ServerMenuButton(this.server, {super.key, this.onViewLog, this.onDeleted});
  final Server server;
  final VoidCallback? onViewLog;

  /// Runs once the server is deleted, so a detail page can close.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(serverActionsProvider.select((m) => m.containsKey(server.id)));
    final g = server.status.group;
    final enabled = !pending && g != StatusGroup.busy;
    return PopupMenuButton<String>(
      tooltip: 'Actions for ${server.name}',
      icon: const Icon(AppIcons.more),
      onSelected: (v) {
        switch (v) {
          case 'start':
            runAction(context, ref, server, ServerAction.start);
          case 'own':
            runAction(context, ref, server, ServerAction.start, useOwnCredits: true);
          case 'stop':
            runAction(context, ref, server, ServerAction.stop);
          case 'restart':
            runAction(context, ref, server, ServerAction.restart);
          case 'extend':
            extendTimer(context, ref, server);
          case 'log':
            onViewLog?.call();
          case 'share':
            shareServerLog(context, ref, server);
          case 'delete':
            deleteServerFlow(context, ref, server, onDeleted: onDeleted);
        }
      },
      itemBuilder: (_) => [
        if (g == StatusGroup.offline || g == StatusGroup.crashed) ...[
          PopupMenuItem(value: 'start', enabled: enabled, child: const Text('Start')),
          if (server.shared) PopupMenuItem(value: 'own', enabled: enabled, child: const Text('Start with my credits')),
        ],
        if (g == StatusGroup.online) ...[
          PopupMenuItem(value: 'stop', enabled: enabled, child: const Text('Stop')),
          PopupMenuItem(value: 'restart', enabled: enabled, child: const Text('Restart')),
          const PopupMenuItem(value: 'extend', child: Text('Extend stop timer')),
        ],
        if (onViewLog != null) const PopupMenuItem(value: 'log', child: Text('View log')),
        // Also in the console toolbar when there is room; here at any width.
        const PopupMenuItem(value: 'share', child: Text('Share log on mclo.gs')),
        // Only the owner can delete; Share Access never allows it.
        if (server.isOwner)
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete server', style: TextStyle(color: context.tokens.error)),
          ),
      ],
    );
  }
}

Future<void> extendTimer(BuildContext context, WidgetRef ref, Server server) async {
  final minutes = await showDialog<int>(
    context: context,
    builder: (c) => SimpleDialog(
      title: const Text('Extend stop timer'),
      children: [
        for (final m in const [5, 15, 30, 60])
          SimpleDialogOption(
            onPressed: () => Navigator.pop(c, m),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text('$m minutes')),
          ),
      ],
    ),
  );
  if (minutes == null) return;
  final client = ref.read(clientProvider);
  try {
    await client?.extendStopTime(server.id, minutes * 60);
    if (context.mounted) showMessage(context, 'Stop timer extended by $minutes minutes');
  } on ExarotonException catch (e) {
    if (context.mounted) showMessage(context, e.message, tone: Tone.error);
  }
}
