import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../ui/app_icons.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import 'servers.dart';

/// Files tried for a server's icon, in order. `server-icon.png` is the one
/// Minecraft shows in the server list; `icon.png` is used when it is there
/// even though the game ignores it, as on Bedrock.
const serverIconFiles = ['server-icon.png', 'icon.png'];

/// Larger files are not shown; a server icon is 64 by 64 pixels.
const serverIconMaxBytes = 1024 * 1024;

/// Whether [bytes] start like a PNG, JPEG, GIF or WebP file.
bool looksLikeImage(List<int> bytes) {
  bool starts(List<int> magic, [int at = 0]) {
    if (bytes.length < at + magic.length) return false;
    for (var i = 0; i < magic.length; i++) {
      if (bytes[at + i] != magic[i]) return false;
    }
    return true;
  }

  return starts(const [0x89, 0x50, 0x4E, 0x47]) || // PNG
      starts(const [0xFF, 0xD8, 0xFF]) || // JPEG
      starts(const [0x47, 0x49, 0x46, 0x38]) || // GIF
      (starts(const [0x52, 0x49, 0x46, 0x46]) && starts(const [0x57, 0x45, 0x42, 0x50], 8)); // WebP
}

/// The first of [serverIconFiles] that exists and is an image, or null.
/// Never throws: a missing file or no file access means no icon.
Future<Uint8List?> loadServerIcon(ExarotonClient client, String serverId) async {
  for (final file in serverIconFiles) {
    try {
      final bytes = await client.readFile(serverId, file);
      if (bytes.length <= serverIconMaxBytes && looksLikeImage(bytes)) return bytes;
    } on ExarotonException {
      // Not there, or not allowed: try the next name.
    }
  }
  return null;
}

/// A server's own icon, fetched once per account session. Null when it has
/// none or this account cannot read its files.
final serverIconProvider = FutureProvider.family<Uint8List?, String>((ref, id) async {
  final client = ref.watch(clientProvider);
  // Whether files may be read, without reloading on every status change.
  final canRead = ref.watch(serverByIdProvider(id).select((s) => s?.allows('file') ?? false));
  if (client == null || !canRead) return null;
  return loadServerIcon(client, id);
});

/// The server's icon with its platform, Java or Bedrock, as a small badge.
///
/// Shows the server's own image when it has one. Without one, a Bedrock
/// server shows the Bedrock mark and any other server its initial.
class ServerIcon extends ConsumerWidget {
  const ServerIcon(this.server, {super.key, this.size = 44, this.showPlatform = true});
  final Server server;
  final double size;

  /// Draws the Java or Bedrock badge at the corner.
  final bool showPlatform;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final bytes = ref.watch(serverIconProvider(server.id)).value;
    final software = server.software;
    final bedrock = software != null && !software.isJava;
    final radius = BorderRadius.circular(size * 0.24);

    final Widget fallback = bedrock
        ? Icon(AppIcons.bedrock, size: size * 0.6, color: t.onSurface)
        : Text(
            server.name.isEmpty ? '?' : String.fromCharCode(server.name.runes.first).toUpperCase(),
            style: TextStyle(color: t.onSurface, fontWeight: FontWeight.w800, fontSize: size * 0.42),
          );
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: t.outline, borderRadius: radius),
      child: bytes == null
          ? fallback
          : Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              // Server icons are pixel art; keep the edges sharp.
              filterQuality: FilterQuality.none,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => fallback,
            ),
    );

    // The Bedrock mark already says the platform.
    final badge = showPlatform && software != null && !(bedrock && bytes == null);
    final platform = software == null ? null : (bedrock ? 'Bedrock' : 'Java');
    return Semantics(
      image: true,
      label: platform == null ? 'Server icon' : '$platform server icon',
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            tile,
            if (badge)
              Positioned(
                right: -size * 0.12,
                bottom: -size * 0.12,
                child: Tooltip(
                  message: '$platform edition',
                  child: Container(
                    width: size * 0.46,
                    height: size * 0.46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.outline),
                    ),
                    child: Icon(bedrock ? AppIcons.bedrock : AppIcons.java, size: size * 0.3, color: t.onSurface),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
