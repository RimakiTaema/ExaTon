import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/components.dart';
import '../../ui/tokens.dart';
import '../credits/credits.dart';
import '../credits/estimate.dart';
import 'live_session.dart';

/// Desktop panel next to the console: players, the paying pool and recent
/// activity.
class ConsoleSidePanel extends ConsumerWidget {
  const ConsoleSidePanel({super.key, required this.session});
  final LiveSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final overview = ref.watch(creditsOverviewProvider).value;
    final label = TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 15);

    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final server = session.server;
        final poolId = overview?.payerOf[server.id];
        final pool = poolId == null ? null : overview!.poolSummaries[poolId];
        return ListView(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Players online - ${server.players.count}', style: label),
                  const SizedBox(height: 8),
                  if (server.players.list.isEmpty)
                    Text(
                      server.players.count == 0 ? 'Nobody yet' : 'Names not reported',
                      style: TextStyle(color: t.onSurfaceMuted),
                    )
                  else
                    for (final p in server.players.list)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(p, style: const TextStyle(fontSize: 17)),
                      ),
                ],
              ),
            ),
            if (pool != null) ...[
              const SizedBox(height: 16),
              AppCard(
                borderColor: pool.low ? t.warning : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pool.name, style: label),
                    const SizedBox(height: 6),
                    CreditsAmount(pool.credits, size: 26),
                    if (pool.estimate?.timeLeft != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${formatTimeLeft(pool.estimate!.timeLeft!)} left at ${formatPerHour(pool.estimate!.creditsPerHour)} / hour',
                          style: TextStyle(color: pool.low ? t.warning : t.onSurfaceMuted, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent activity', style: label),
                  const SizedBox(height: 8),
                  if (session.activity.isEmpty)
                    Text('Nothing since you opened this server', style: TextStyle(color: t.onSurfaceMuted))
                  else
                    for (final a in session.activity.take(12))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.text, style: const TextStyle(fontSize: 16)),
                            Text(formatClock(a.time), style: TextStyle(color: t.onSurfaceMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
