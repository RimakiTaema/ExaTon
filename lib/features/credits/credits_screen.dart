import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/motion.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import '../settings/settings.dart';
import '../charts/time_series_chart.dart';
import 'alerts.dart';
import 'credits.dart';
import 'top_up.dart';
import 'estimate.dart';
import '../../ui/app_icons.dart';

Tone timeLeftTone(PayerSummary p) => p.low ? Tone.warning : Tone.success;

Color timeLeftColor(BuildContext context, PayerSummary p) => context.tokens.tone(timeLeftTone(p));

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final overview = ref.watch(creditsOverviewProvider);
    final account = ref.watch(activeAccountProvider);
    final method = ref.watch(settingsProvider.select((s) => s.estimateMethod));

    return RefreshIndicator(
      onRefresh: () async {
        refreshCredits(ref.invalidate);
        await ref.read(creditsOverviewProvider.future);
      },
      child: switch (overview) {
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.fromLTRB(gutter, 16, gutter, 32),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                Semantics(header: true, child: Text('Credits', style: Theme.of(context).textTheme.headlineLarge)),
                TextButton.icon(
                  onPressed: () => refreshCredits(ref.invalidate),
                  icon: Icon(AppIcons.refresh, color: t.onSurfaceMuted),
                  label: Text(
                    'Updated ${formatClock(value.updated)}',
                    style: TextStyle(color: t.onSurfaceMuted, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your account', style: TextStyle(color: t.onSurfaceMuted, fontSize: 16)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: CreditsAmount(value.account.credits, size: 40)),
                      Text(account?.name ?? '', style: TextStyle(color: t.onSurfaceMuted, fontSize: 16)),
                    ],
                  ),
                  _EstimateLine(value.accountSummary),
                  const SizedBox(height: 14),
                  const TopUpButton(),
                ],
              ),
            ),
            if (account != null) ...[
              const SizedBox(height: 14),
              BalanceGraphCard(owner: sampleOwner(account.id), title: 'Balance history'),
            ],
            SectionHeader(
              'Credit pools',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.locked, size: 18, color: t.onSurfaceMuted),
                  const SizedBox(width: 6),
                  const Text('View only'),
                ],
              ),
            ),
            if (value.pools.isEmpty)
              Text('You are not in any credit pool.', style: TextStyle(color: t.onSurfaceMuted))
            else
              for (final p in value.pools) ...[
                FadeSlideIn(
                  index: value.pools.indexOf(p) + 1,
                  child: _PoolCard(pool: p, summary: value.poolSummaries[p.id]!),
                ),
                const SizedBox(height: 14),
              ],
            SectionHeader('Running now', trailing: const Text('credits per hour')),
            if (value.running.isEmpty)
              Text('No servers are running.', style: TextStyle(color: t.onSurfaceMuted))
            else
              CardList(
                children: [
                  for (final r in value.running)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      title: Text(r.server.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                      subtitle: Text('Paid by ${r.payerName}', style: TextStyle(color: t.onSurfaceMuted, fontSize: 15)),
                      trailing: Text(
                        r.creditsPerHour == null ? 'unknown' : formatPerHour(r.creditsPerHour!),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            InfoNote(
              method == EstimateMethod.runningServers
                  ? 'Time left is an estimate: pool credits divided by the hourly cost of servers running now '
                        '(1 credit per GB of RAM per hour). Storage, 10 credits per server per month, is not included. '
                        'Deposits and member changes are done on exaroton.'
                  : 'Time left is an estimate from how fast the balance fell over the last 6 hours. '
                        'It needs at least 30 minutes of samples. Deposits and member changes are done on exaroton.',
            ),
          ],
        ),
        AsyncError(:final error) => ListView(
          children: [
            const SizedBox(height: 120),
            ErrorPanel(error, onRetry: () => refreshCredits(ref.invalidate)),
          ],
        ),
        _ => const Loading(),
      },
    );
  }
}

class _EstimateLine extends StatelessWidget {
  const _EstimateLine(this.p);
  final PayerSummary p;

  @override
  Widget build(BuildContext context) {
    final e = p.estimate;
    if (e == null || e.timeLeft == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        '${formatTimeLeft(e.timeLeft!)} left at ${formatPerHour(e.creditsPerHour)} / hour - ${e.label.toLowerCase()}',
        style: TextStyle(color: timeLeftColor(context, p), fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PoolCard extends StatelessWidget {
  const _PoolCard({required this.pool, required this.summary});
  final CreditPool pool;
  final PayerSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final left = summary.estimate?.timeLeft;
    return AppCard(
      borderColor: summary.low ? t.warning : null,
      semanticLabel:
          '${pool.name}, ${formatCredits(pool.credits)} credits'
          '${left != null ? ', ${formatTimeLeft(left)} left' : ''}',
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PoolDetailScreen(poolId: pool.id))),
      padding: const EdgeInsets.fromLTRB(22, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(pool.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              Icon(AppIcons.next, color: t.onSurfaceMuted),
            ],
          ),
          const SizedBox(height: 6),
          // The time-left pill sits at the right, or below at large text.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CreditsAmount(pool.credits, size: 30),
                  Text(
                    '${pool.members} ${pool.members == 1 ? 'member' : 'members'} - '
                    '${pool.servers} ${pool.servers == 1 ? 'server' : 'servers'}',
                    style: TextStyle(color: t.onSurfaceMuted, fontSize: 16),
                  ),
                ],
              ),
              if (left != null) Pill('${formatTimeLeft(left)} left', tone: timeLeftTone(summary)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Balance over time for the account or one pool, from the samples taken on
/// each balance fetch, with a range selector and a way to clear them.
class BalanceGraphCard extends ConsumerStatefulWidget {
  const BalanceGraphCard({super.key, required this.owner, required this.title});

  /// Sample owner key, see [sampleOwner].
  final String owner;
  final String title;

  @override
  ConsumerState<BalanceGraphCard> createState() => _BalanceGraphCardState();
}

class _BalanceGraphCardState extends ConsumerState<BalanceGraphCard> {
  BalanceRange _range = BalanceRange.day;

  Future<void> _clear() async {
    final ok = await confirm(
      context,
      title: 'Clear balance history?',
      body:
          'The recorded balance samples on this device are deleted. '
          'The "recent usage" time-left estimate starts over.',
      action: 'Clear history',
      destructive: true,
    );
    if (!ok) return;
    await clearBalanceHistory(ref, widget.owner);
    if (mounted) showMessage(context, 'Balance history cleared');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final all = ref.watch(balanceHistoryProvider(widget.owner)).value;
    final shown = all == null ? const <BalanceSample>[] : samplesInWindow(all, _range.window, now: DateTime.now());
    final change = shown.length < 2 ? null : shown.last.credits - shown.first.credits;
    final muted = TextStyle(color: t.onSurfaceMuted, fontSize: 15);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(widget.title, style: TextStyle(color: t.onSurfaceMuted, fontSize: 16)),
              SegmentedButton<BalanceRange>(
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: [for (final r in BalanceRange.values) ButtonSegment(value: r, label: Text(r.label))],
                selected: {_range},
                onSelectionChanged: (s) => setState(() => _range = s.first),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (all == null)
            const SizedBox(height: 120, child: Loading())
          else if (shown.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  all.isEmpty
                      ? 'No samples yet. The balance is recorded every 15 minutes while the app is open.'
                      : 'No samples in the last ${_range.label}.',
                  textAlign: TextAlign.center,
                  style: muted,
                ),
              ),
            )
          else
            TimeSeriesChart(
              points: [for (final s in shown) (t: s.time, value: s.credits)],
              formatValue: formatCredits,
              semanticLabel: '${widget.title}, last ${_range.label}',
              showDate: _range != BalanceRange.sixHours,
              height: 140,
            ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              Text(
                [
                  '${shown.length} ${shown.length == 1 ? 'sample' : 'samples'}',
                  if (change != null) '${change >= 0 ? '+' : '-'}${formatCredits(change.abs())} credits',
                ].join(' - '),
                style: muted,
              ),
              if (all != null && all.isNotEmpty) TextButton(onPressed: _clear, child: const Text('Clear history')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pool detail: balance with time left, servers in the pool, members.
class PoolDetailScreen extends ConsumerStatefulWidget {
  const PoolDetailScreen({super.key, required this.poolId});
  final String poolId;

  @override
  ConsumerState<PoolDetailScreen> createState() => _PoolDetailScreenState();
}

class _PoolDetailScreenState extends ConsumerState<PoolDetailScreen> {
  bool _allMembers = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final overview = ref.watch(creditsOverviewProvider).value;
    final pool = overview?.pools.where((p) => p.id == widget.poolId).firstOrNull;
    final summary = overview?.poolSummaries[widget.poolId];
    final servers = ref.watch(poolServersProvider(widget.poolId));
    final members = ref.watch(poolMembersProvider(widget.poolId));
    final settings = ref.watch(settingsProvider);
    final myName = ref.watch(accountInfoProvider).value?.name;

    if (pool == null || summary == null || overview == null) {
      return Scaffold(appBar: AppBar(), body: const Loading());
    }

    final live = {for (final r in overview.running) r.server.id: r};

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pool.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text(
              'Updated ${formatClock(overview.updated)} - view only',
              style: TextStyle(color: t.onSurfaceMuted, fontSize: 15),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(gutter, 8, gutter, 24),
        children: [
          PoolBalanceCard(
            summary: summary,
            thresholdDays: settings.alertThresholdDays,
            alertsOn: settings.alertsOnFor(pool.id),
          ),
          if (ref.watch(activeAccountProvider) case final account?) ...[
            const SizedBox(height: 14),
            BalanceGraphCard(owner: sampleOwner(account.id, pool.id), title: 'Pool balance history'),
          ],
          SectionHeader('Servers in pool', trailing: Text('${pool.servers}')),
          switch (servers) {
            AsyncData(:final value) when value.isEmpty => Text(
              'No servers in this pool.',
              style: TextStyle(color: t.onSurfaceMuted),
            ),
            AsyncData(:final value) => CardList(
              children: [
                for (final s in value)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    subtitle: Text(
                      live[s.id]?.creditsPerHour != null
                          ? '${formatPerHour(live[s.id]!.creditsPerHour!)} credits / hour'
                          : (s.status.isBilled ? 'Running' : 'Not running'),
                      style: TextStyle(color: t.onSurfaceMuted),
                    ),
                    trailing: StatusLabel(live[s.id]?.server.status ?? s.status),
                  ),
              ],
            ),
            AsyncError(:final error) => InfoNote(describeError(error).body, icon: AppIcons.error),
            _ => const SizedBox(height: 80, child: Loading()),
          },
          const SectionHeader('Members', trailing: Text('Share of pool - not spendable')),
          switch (members) {
            AsyncData(:final value) => () {
              final sorted = [...value]..sort((a, b) => b.share.compareTo(a.share));
              final shown = _allMembers ? sorted : sorted.take(3).toList();
              return CardList(
                children: [
                  for (final m in shown)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      leading: Avatar(m.name, highlight: m.name == myName),
                      title: Text(m.name == myName ? '${m.name} (you)' : m.name, style: const TextStyle(fontSize: 18)),
                      subtitle: Text(
                        '${formatCredits(m.credits)} credits share of pool',
                        style: TextStyle(color: t.onSurfaceMuted),
                      ),
                      trailing: Text(
                        '${(m.share * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ),
                  if (sorted.length > 3)
                    TextButton(
                      onPressed: () => setState(() => _allMembers = !_allMembers),
                      child: Text(_allMembers ? 'Show fewer' : 'Show all ${sorted.length} members'),
                    ),
                ],
              );
            }(),
            AsyncError(:final error) when error is ExarotonException && error.isForbidden => InfoNote(
              'You need the "View members" permission on this pool to see members. '
              'Your own share is ${(pool.ownShare * 100).round()}% (${formatCredits(pool.ownCredits)} credits).',
              icon: AppIcons.locked,
            ),
            AsyncError(:final error) => InfoNote(describeError(error).body, icon: AppIcons.error),
            _ => const SizedBox(height: 80, child: Loading()),
          },
        ],
      ),
      // Grows with the text size; no fixed height.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(gutter, 8, gutter, 12),
          // Side by side normally, stacked full width at large text.
          child: Flex(
            direction: MediaQuery.textScalerOf(context).scale(1) > 1.3 ? Axis.vertical : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: MediaQuery.textScalerOf(context).scale(1) > 1.3
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.center,
            children: [
              Flexible(
                fit: MediaQuery.textScalerOf(context).scale(1) > 1.3 ? FlexFit.loose : FlexFit.tight,
                flex: MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 0 : 1,
                child: FilledButton.icon(
                  onPressed: () => ref.read(topUpLauncherProvider)(context, TopUpTarget.pool(pool.name)),
                  icon: const Icon(AppIcons.topUp, size: 20),
                  label: const Text('Deposit'),
                ),
              ),
              const SizedBox(width: 12, height: 10),
              // Alerts for this pool only. Turning them on when alerts are
              // off globally turns the global switch on too.
              Builder(
                builder: (context) {
                  final on = settings.alertsOnFor(pool.id);
                  return OutlinedButton.icon(
                    onPressed: () async {
                      final n = ref.read(settingsProvider.notifier);
                      if (on) {
                        await n.update((s) => s.copyWith(mutedPools: {...s.mutedPools, pool.id}));
                      } else {
                        if (!settings.alertsEnabled) await CreditAlerts.instance.requestPermission();
                        await n.update(
                          (s) => s.copyWith(alertsEnabled: true, mutedPools: {...s.mutedPools}..remove(pool.id)),
                        );
                      }
                      if (context.mounted) {
                        showMessage(context, on ? 'Alerts off for ${pool.name}' : 'Alerts on for ${pool.name}');
                      }
                    },
                    style: on
                        ? OutlinedButton.styleFrom(
                            foregroundColor: t.onSelectedFill,
                            side: BorderSide(color: t.primary),
                            backgroundColor: t.selectedFill,
                          )
                        : null,
                    icon: Icon(on ? AppIcons.alertsOn : AppIcons.alertsOff),
                    label: Text(on ? 'Alerts on' : 'Alerts off'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pool credits, rate, a time-left bar with the alert marker, and a warning
/// when under the threshold.
class PoolBalanceCard extends StatelessWidget {
  const PoolBalanceCard({super.key, required this.summary, required this.thresholdDays, this.alertsOn = true});
  final PayerSummary summary;
  final int thresholdDays;
  final bool alertsOn;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final e = summary.estimate;
    final left = e?.timeLeft;
    // Bar spans twice the threshold so the marker sits in the middle.
    final span = Duration(days: thresholdDays * 2);
    final frac = left == null ? 1.0 : (left.inMinutes / span.inMinutes).clamp(0.0, 1.0);
    final color = summary.low ? t.warning : t.success;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance and rate side by side, rate at the right as in the
          // mockup; at large text the rate becomes one line below.
          LayoutBuilder(
            builder: (context, c) {
              final balance = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pool credits', style: TextStyle(color: t.onSurfaceMuted, fontSize: 16)),
                  CreditsAmount(summary.credits, size: 40),
                ],
              );
              if (e == null) return balance;
              final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.2 || c.maxWidth < 300;
              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    balance,
                    const SizedBox(height: 6),
                    Text(
                      'Using ${formatPerHour(e.creditsPerHour)} credits / hour',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: balance),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Using', style: TextStyle(color: t.onSurfaceMuted, fontSize: 16)),
                      Text(
                        '${formatPerHour(e.creditsPerHour)} / hour',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Semantics(
            label: left == null
                ? 'Time left unknown'
                : 'Time left ${formatTimeLeft(left)}, alert at $thresholdDays days',
            excludeSemantics: true,
            child: LayoutBuilder(
              builder: (_, c) => SizedBox(
                height: 26,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: AnimatedBar(value: frac, color: color, background: t.background),
                    ),
                    Positioned(
                      left: c.maxWidth / 2 - 1,
                      top: 0,
                      child: Container(width: 2.5, height: 26, color: t.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 2,
            children: [
              Text(
                left == null
                    ? (e == null ? 'Time left: not enough data yet' : 'Time left: nothing running')
                    : 'Time left: ${formatTimeLeft(left).replaceFirst('~', '')}',
                style: TextStyle(color: t.onSurfaceMuted),
              ),
              Text('Alert at $thresholdDays days', style: TextStyle(color: t.onSurfaceMuted)),
            ],
          ),
          if (e != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(e.label, style: TextStyle(color: t.onSurfaceMuted, fontSize: 13)),
            ),
          if (summary.low) ...[
            const SizedBox(height: 16),
            WarningBanner(
              alertsOn
                  ? 'Below your alert threshold. You are notified when time left drops under $thresholdDays days.'
                  : 'Below your alert threshold of $thresholdDays days. Alerts for this pool are off.',
            ),
          ],
        ],
      ),
    );
  }
}

/// Pool tab of a server: which pool pays for it.
class ServerPoolTab extends ConsumerWidget {
  const ServerPoolTab({super.key, required this.server});
  final Server server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final overview = ref.watch(creditsOverviewProvider);
    final threshold = ref.watch(settingsProvider.select((s) => s.alertThresholdDays));
    return switch (overview) {
      AsyncData(:final value) => () {
        final poolId = value.payerOf[server.id];
        final summary = poolId == null ? null : value.poolSummaries[poolId];
        if (summary == null) {
          return ListView(
            children: [
              InfoNote(
                server.shared
                    ? 'This server is shared with you. Its owner pays for it unless you start it with your own credits.'
                    : 'This server is not in a credit pool. Your account pays for it.',
              ),
            ],
          );
        }
        return ListView(
          children: [
            Text('Paid by', style: TextStyle(color: t.onSurfaceMuted, fontSize: 16)),
            const SizedBox(height: 4),
            Text(summary.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            PoolBalanceCard(
              summary: summary,
              thresholdDays: threshold,
              alertsOn: ref.watch(settingsProvider).alertsOnFor(summary.poolId!),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PoolDetailScreen(poolId: poolId!))),
              child: const Text('Open pool'),
            ),
          ],
        );
      }(),
      AsyncError(:final error) => ErrorPanel(error),
      _ => const Loading(),
    };
  }
}
