import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/motion.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import '../console/live_session.dart';
import '../credits/credits.dart';
import '../charts/time_series_chart.dart';
import 'logs_tab.dart';
import 'server_actions.dart';
import 'stats_history.dart';
import '../../ui/app_icons.dart';

final _ramProvider = FutureProvider.autoDispose.family<int, String>((ref, id) => requireClient(ref).getRam(id));
final _motdProvider = FutureProvider.autoDispose.family<String, String>((ref, id) => requireClient(ref).getMotd(id));

class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key, required this.server, this.onViewLog, this.onDeleted});
  final Server server;

  /// Opens the Logs tab.
  final VoidCallback? onViewLog;

  /// Runs once the server is deleted, so a detail page can close.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final session = ref.watch(liveSessionProvider(server.id));
    final label = TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 15);
    final canEditOptions = server.allows('options') || !server.shared;
    final software = server.software;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (session != null)
          ListenableBuilder(
            listenable: session,
            builder: (context, _) => _LiveStats(session: session, showRam: canEditOptions),
          ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address', style: label),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: SelectableText(server.address, style: const TextStyle(fontSize: 17))),
                  IconButton(
                    tooltip: 'Copy address',
                    icon: const Icon(AppIcons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: server.address));
                      showMessage(context, 'Address copied');
                    },
                  ),
                ],
              ),
              if (server.status == ServerStatus.online) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => extendTimer(context, ref, server),
                  icon: const Icon(AppIcons.timer),
                  label: const Text('Extend stop timer'),
                ),
              ],
              if (server.status == ServerStatus.crashed) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onViewLog ?? () => shareServerLog(context, ref, server),
                  icon: const Icon(AppIcons.textFile),
                  label: const Text('View log'),
                ),
              ],
            ],
          ),
        ),
        if (software != null) ...[
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Software', style: label),
                const SizedBox(height: 4),
                Text('$software', style: const TextStyle(fontSize: 17)),
                if (software.addons != null && software.addons!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Supports: ${software.addons!.join(', ')}', style: TextStyle(color: t.onSurfaceMuted)),
                ],
                // Share Access names no software permission, so only the
                // owner is offered the change.
                if (server.isOwner) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => changeSoftwareFlow(context, ref, server),
                    child: const Text('Change software'),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (canEditOptions) ...[
          const SizedBox(height: 16),
          _RamCard(server: server),
          const SizedBox(height: 16),
          _MotdCard(server: server),
        ],
        if (server.isOwner) ...[
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delete server', style: label),
                const SizedBox(height: 4),
                Text(
                  'Permanently deletes the server and all of its files. The server must be offline.',
                  style: TextStyle(color: t.onSurfaceMuted, height: 1.4),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => deleteServerFlow(context, ref, server, onDeleted: onDeleted),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.error,
                    side: BorderSide(color: t.error),
                  ),
                  icon: const Icon(AppIcons.delete),
                  label: const Text('Delete server'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LiveStats extends ConsumerWidget {
  const _LiveStats({required this.session, required this.showRam});
  final LiveSession session;

  /// Whether the account may read the RAM option (a shared server may not).
  final bool showRam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final s = session.server;
    final label = TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 15);
    final mem = session.memory;
    final tick = session.tick;
    final heap = session.heap;
    final history = ref.watch(statsHistoryProvider(s.id));
    final ramGb = ref.watch(ramCacheProvider).value?[s.id] ?? (showRam ? ref.watch(_ramProvider(s.id)).value : null);

    List<ChartPoint> series(double? Function(StatsPoint p) pick) => [
      for (final p in history)
        if (pick(p) != null) (t: p.t, value: pick(p)!),
    ];
    final memSeries = series((p) => p.memoryMb);
    final tickSeries = series((p) => p.tickMs);
    final tpsSeries = series((p) => p.tps);
    final ramMb = ramGb == null ? null : ramGb * 1024.0;
    String mb(double v) => formatBytes((v * 1024 * 1024).round());

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text('Live', style: label),
              StatusLabel(s.status, suffix: '${s.players.count} / ${s.players.max}'),
            ],
          ),
          if (ramGb != null) ...[
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$ramGb GB',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.3),
                  ),
                  TextSpan(
                    text: ' RAM allocated',
                    style: TextStyle(color: t.onSurfaceMuted, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
          // Readings whose stream is unavailable are hidden, never shown as zero.
          if (mem != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('Memory', style: TextStyle(fontSize: 16))),
                Text(
                  '${mem.percent.toStringAsFixed(0)}% - ${formatBytes(mem.usage)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Semantics(
              label: 'Memory ${mem.percent.toStringAsFixed(0)} percent',
              child: AnimatedBar(value: mem.percent / 100),
            ),
            if (heap != null) ...[
              const SizedBox(height: 6),
              Text('Java heap ${formatBytes(heap)}', style: TextStyle(color: t.onSurfaceMuted)),
            ],
          ],
          if (memSeries.isNotEmpty) ...[
            const SizedBox(height: 12),
            TimeSeriesChart(
              points: memSeries,
              formatValue: mb,
              semanticLabel: 'Memory use over time',
              minY: 0,
              // The allocation is the ceiling while the readings fit under it.
              maxY: ramMb != null && memSeries.every((p) => p.value <= ramMb) ? ramMb : null,
            ),
          ],
          if (tick != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('Tick time', style: TextStyle(fontSize: 16))),
                Text(
                  '${tick.toStringAsFixed(1)} ms',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: tick > 50 ? t.warning : t.onSurface,
                  ),
                ),
              ],
            ),
          ],
          if (tickSeries.isNotEmpty) ...[
            const SizedBox(height: 12),
            TimeSeriesChart(
              points: tickSeries,
              formatValue: (v) => '${v.toStringAsFixed(1)} ms',
              semanticLabel: 'Tick time over time',
              minY: 0,
            ),
          ],
          // Only when the stream reports TPS itself.
          if (tpsSeries.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('TPS', style: TextStyle(fontSize: 16))),
                Text(
                  tpsSeries.last.value.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TimeSeriesChart(
              points: tpsSeries,
              formatValue: (v) => v.toStringAsFixed(1),
              semanticLabel: 'Ticks per second over time',
              minY: 0,
              maxY: 20,
            ),
          ],
          if (s.players.list.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Players', style: label),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final p in s.players.list) Chip(label: Text(p))]),
          ],
          if (history.isEmpty && s.status == ServerStatus.online) ...[
            const SizedBox(height: 12),
            Text('No samples yet - stats stream in progress.', style: TextStyle(color: t.onSurfaceMuted)),
          ],
          if (s.status != ServerStatus.online) ...[
            const SizedBox(height: 12),
            Text(
              history.isEmpty
                  ? 'Memory and tick time show while the server is online.'
                  : 'The server is ${s.status.label.toLowerCase()}. The charts show the last readings.',
              style: TextStyle(color: t.onSurfaceMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _RamCard extends ConsumerStatefulWidget {
  const _RamCard({required this.server});
  final Server server;
  @override
  ConsumerState<_RamCard> createState() => _RamCardState();
}

class _RamCardState extends ConsumerState<_RamCard> {
  double? _draft;
  bool _saving = false;

  Future<void> _save(int gb) async {
    setState(() => _saving = true);
    try {
      final saved = await ref.read(clientProvider)!.setRam(widget.server.id, gb);
      await ref.read(ramCacheProvider.notifier).set(widget.server.id, saved);
      ref.invalidate(_ramProvider(widget.server.id));
      if (mounted) showMessage(context, 'RAM set to $saved GB. It applies on the next start.');
      setState(() => _draft = null);
    } on ExarotonException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ram = ref.watch(_ramProvider(widget.server.id));
    return AppCard(
      child: switch (ram) {
        AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'RAM',
                    style: TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                Text(
                  '${(_draft ?? value.toDouble()).round()} GB',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ],
            ),
            Slider(
              value: (_draft ?? value.toDouble()).clamp(2, 16),
              min: 2,
              max: 16,
              divisions: 14,
              label: '${(_draft ?? value.toDouble()).round()} GB',
              onChanged: (v) => setState(() => _draft = v),
            ),
            Text(
              'Changes apply on the next start. Each GB costs about 1 credit per hour while running.',
              style: TextStyle(color: t.onSurfaceMuted),
            ),
            if (_draft != null && _draft!.round() != value) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: _saving ? null : () => _save(_draft!.round()), child: const Text('Save RAM')),
            ],
          ],
        ),
        AsyncError(:final error) => Text('RAM: $error', style: TextStyle(color: t.onSurfaceMuted)),
        _ => const SizedBox(height: 60, child: Loading()),
      },
    );
  }
}

class _MotdCard extends ConsumerStatefulWidget {
  const _MotdCard({required this.server});
  final Server server;
  @override
  ConsumerState<_MotdCard> createState() => _MotdCardState();
}

class _MotdCardState extends ConsumerState<_MotdCard> {
  TextEditingController? _c;
  bool _saving = false;

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(clientProvider)!.setMotd(widget.server.id, _c!.text);
      ref.invalidate(_motdProvider(widget.server.id));
      if (mounted) showMessage(context, 'MOTD saved');
    } on ExarotonException catch (e) {
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motd = ref.watch(_motdProvider(widget.server.id));
    return AppCard(
      child: switch (motd) {
        AsyncData(:final value) => () {
          _c ??= TextEditingController(text: value);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'MOTD',
                style: TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _c,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Message of the day'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: _saving ? null : _save, child: const Text('Save MOTD')),
              ),
            ],
          );
        }(),
        AsyncError(:final error) => Text('MOTD: $error', style: TextStyle(color: t.onSurfaceMuted)),
        _ => const SizedBox(height: 60, child: Loading()),
      },
    );
  }
}
