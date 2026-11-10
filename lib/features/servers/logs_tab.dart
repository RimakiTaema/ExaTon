import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../ui/app_icons.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';

/// The most lines of a log the panel renders. A long log shows its end,
/// where a crash is reported.
const logMaxLines = 2000;

/// The server log from `GET /servers/{id}/logs/`.
final serverLogProvider = FutureProvider.autoDispose.family<String, String>((ref, id) => requireClient(ref).getLog(id));

/// The last [max] lines of [content], and how many earlier lines were left
/// out. Blank lines at the end are dropped.
({List<String> lines, int hidden}) tailLines(String content, {int max = logMaxLines}) {
  final all = content.replaceAll('\r\n', '\n').split('\n');
  while (all.isNotEmpty && all.last.trim().isEmpty) {
    all.removeLast();
  }
  final hidden = all.length > max ? all.length - max : 0;
  return (lines: hidden == 0 ? all : all.sublist(hidden), hidden: hidden);
}

/// The link to open for a shared log, or null when the API returned nothing
/// usable. Only http and https links are opened.
Uri? sharedLogUri(SharedLog log) {
  final uri = Uri.tryParse(log.url.trim());
  if (uri == null || !uri.hasAuthority || !(uri.isScheme('https') || uri.isScheme('http'))) return null;
  return uri;
}

/// Uploads the log to mclo.gs and opens the link.
Future<void> shareServerLog(BuildContext context, WidgetRef ref, Server server) async {
  final client = ref.read(clientProvider);
  if (client == null) return;
  try {
    final uri = sharedLogUri(await client.shareLog(server.id));
    if (uri == null) {
      if (context.mounted) showMessage(context, 'mclo.gs did not return a link');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on ExarotonException catch (e) {
    if (context.mounted) showMessage(context, e.message);
  }
}

/// The server's log file: read, refresh, copy and share.
class LogsTab extends ConsumerWidget {
  const LogsTab({super.key, required this.server});
  final Server server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final log = ref.watch(serverLogProvider(server.id));
    final content = log.value;
    final hasText = content != null && content.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                log.isLoading ? 'Loading log...' : 'Server log',
                style: TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            LabeledIconButton(
              icon: AppIcons.refresh,
              label: 'Refresh log',
              onPressed: log.isLoading ? null : () => ref.invalidate(serverLogProvider(server.id)),
            ),
            const SizedBox(width: 10),
            LabeledIconButton(
              icon: AppIcons.copy,
              label: 'Copy log',
              onPressed: hasText
                  ? () async {
                      await Clipboard.setData(ClipboardData(text: content));
                      if (context.mounted) showMessage(context, 'Log copied');
                    }
                  : null,
            ),
            const SizedBox(width: 10),
            LabeledIconButton(
              icon: AppIcons.share,
              label: 'Share log on mclo.gs',
              onPressed: () => shareServerLog(context, ref, server),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: switch (log) {
            AsyncData(:final value) when value.trim().isEmpty => EmptyState(
              icon: AppIcons.textFile,
              title: 'No log yet',
              body: server.status == ServerStatus.offline
                  ? 'This server has not written a log. Start it, then refresh.'
                  : 'The log is empty. Refresh in a moment.',
            ),
            AsyncData(:final value) => _LogPanel(content: value),
            AsyncError(:final error) => ErrorPanel(error, onRetry: () => ref.invalidate(serverLogProvider(server.id))),
            _ => const Loading(),
          },
        ),
      ],
    );
  }
}

class _LogPanel extends StatelessWidget {
  const _LogPanel({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (:lines, :hidden) = tailLines(content);
    const mono = TextStyle(fontFamily: monoFont, fontSize: 14, height: 1.45);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hidden > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InfoNote('Showing the last ${lines.length} lines. $hidden earlier lines are hidden; Copy has all.'),
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: t.consoleBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: t.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: SelectionArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lines.length,
                itemBuilder: (_, i) {
                  final line = lines[i];
                  final color = line.contains('ERROR]') || line.contains('FATAL]')
                      ? t.error
                      : line.contains('WARN]')
                      ? t.warning
                      : t.onSurface;
                  return Text(line, style: mono.copyWith(color: color));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
