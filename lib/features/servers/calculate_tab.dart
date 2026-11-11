import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import '../credits/credits.dart';
import '../credits/estimate.dart';
import 'overview_tab.dart' show serverRamProvider;

/// What-if cost calculations for one server.
class CalculateTab extends StatelessWidget {
  const CalculateTab({super.key, required this.server});
  final Server server;

  @override
  Widget build(BuildContext context) => ListView(children: [CostCard(server: server)]);
}

/// Monthly cost at a chosen number of hours a day, from the server's RAM and
/// the storage price. Not saved: it is a what-if.
class CostCard extends ConsumerStatefulWidget {
  const CostCard({super.key, required this.server});
  final Server server;

  @override
  ConsumerState<CostCard> createState() => CostCardState();
}

class CostCardState extends ConsumerState<CostCard> {
  double _hours = 4;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final id = widget.server.id;
    final ram = ref.watch(ramCacheProvider).value?[id] ?? ref.watch(serverRamProvider(id)).value;
    final label = TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 15);
    final h = _hours.round();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly cost', style: label),
          const SizedBox(height: 4),
          if (ram == null)
            Text('Waiting for the RAM size...', style: TextStyle(color: t.onSurfaceMuted))
          else ...[
            Text(
              '~${formatCredits(monthlyCredits(ramGb: ram, hoursPerDay: h.toDouble()))} credits a month',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Running $h ${h == 1 ? 'hour' : 'hours'} a day: '
              '${formatCredits(ram * creditsPerGbHour * h * 30)} for $ram GB of RAM '
              '+ ${storageCreditsPerServerMonth.toStringAsFixed(0)} storage',
              style: TextStyle(color: t.onSurfaceMuted, height: 1.4),
            ),
            Slider(
              value: _hours,
              min: 0,
              max: 24,
              divisions: 24,
              label: '$h h / day',
              semanticFormatterCallback: (v) => '${v.round()} hours a day',
              onChanged: (v) => setState(() => _hours = v),
            ),
            Text(
              'A month is counted as 30 days. Storage is charged even while the server is offline.',
              style: TextStyle(color: t.onSurfaceMuted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
