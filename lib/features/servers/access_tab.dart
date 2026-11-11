import 'package:flutter/material.dart';

import '../../core/exaroton/models.dart';
import '../../ui/app_icons.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';

/// What one Share Access permission lets this account do. Matching is by
/// keyword, like [Server.allows], because the API does not list the names.
String describePermission(String name) {
  final n = name.toLowerCase();
  if (n.contains('console')) return 'Read the console and send commands';
  if (n.contains('player')) return 'Manage player lists: whitelist, operators and bans';
  if (n.contains('file')) return 'Browse, edit, upload and delete server files';
  if (n.contains('config')) return 'Change config options such as server.properties';
  if (n.contains('option')) return 'Change server options such as RAM and MOTD';
  if (n.contains('log')) return 'Read and share the server log';
  if (n.contains('start') || n.contains('stop') || n.contains('restart')) return 'Start, stop and restart the server';
  if (n.contains('software')) return 'Change the server software';
  return 'Granted by the owner';
}

/// A part of the app that Share Access can open or lock.
typedef AccessFeature = ({String label, String detail, bool allowed});

/// The app's permission-gated features and whether [server] allows each.
List<AccessFeature> accessFeatures(Server server) => [
  (label: 'Console', detail: 'Live console and commands', allowed: server.allows('console')),
  (label: 'Players', detail: 'Whitelist, operators and bans', allowed: server.allows('player')),
  (label: 'Files', detail: 'File browser and editor', allowed: server.allows('file')),
  (label: 'Config', detail: 'Every option in any config file', allowed: server.allows('config')),
  (label: 'RAM and MOTD', detail: 'Server options on Overview', allowed: server.allows('options')),
  (label: 'Software', detail: 'Change the server software and version', allowed: server.allows('software')),
  (label: 'Delete server', detail: 'Owner only, never shared', allowed: server.isOwner),
];

/// Share Access for a server shared with this account: the permissions the
/// owner granted, what each gives, and which parts of the app that opens.
class AccessTab extends StatelessWidget {
  const AccessTab({super.key, required this.server});
  final Server server;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600, fontSize: 15);
    final permissions = server.permissions ?? const <String>[];
    final features = accessFeatures(server);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Access', style: label),
                  Pill(server.isOwner ? 'Owner' : 'Shared', tone: server.isOwner ? Tone.success : Tone.warning),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                server.isOwner
                    ? 'You own this server and can do everything.'
                    : 'This server is shared with you by its owner. You can use what the owner granted below; '
                          'the owner changes this on exaroton.',
                style: TextStyle(color: t.onSurfaceMuted, height: 1.4),
              ),
            ],
          ),
        ),
        if (!server.isOwner) ...[
          SectionHeader('Permissions granted', trailing: Text('${permissions.length}')),
          if (permissions.isEmpty)
            const InfoNote('The owner has not granted any permission. You can see the server and its status only.')
          else
            CardList(
              children: [
                for (final p in permissions)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Icon(AppIcons.success, color: t.success),
                    title: Text(p, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                    subtitle: Text(describePermission(p), style: TextStyle(color: t.onSurfaceMuted)),
                  ),
              ],
            ),
        ],
        const SectionHeader('What you can use'),
        CardList(
          children: [
            for (final f in features)
              Semantics(
                label: '${f.label}: ${f.allowed ? 'available' : 'not available'}',
                excludeSemantics: true,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Icon(
                    f.allowed ? AppIcons.check : AppIcons.locked,
                    color: f.allowed ? t.success : t.onSurfaceMuted,
                  ),
                  title: Text(
                    f.label,
                    style: TextStyle(fontSize: 17, color: f.allowed ? t.onSurface : t.onSurfaceMuted),
                  ),
                  subtitle: Text(f.detail, style: TextStyle(color: t.onSurfaceMuted)),
                  trailing: Text(
                    f.allowed ? 'Available' : 'Not available',
                    style: TextStyle(color: f.allowed ? t.success : t.onSurfaceMuted, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
