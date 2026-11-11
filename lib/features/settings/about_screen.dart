import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_info.dart';
import '../../ui/app_icons.dart';
import '../../ui/components.dart';
import '../../ui/tokens.dart';
import '../debug/debug_screen.dart';

final _repo = Uri.parse('https://github.com/RimakiTaema/ExaTon');
final _releases = Uri.parse('https://github.com/RimakiTaema/ExaTon/releases');
final _issues = Uri.parse('https://github.com/RimakiTaema/ExaTon/issues');
final _exaroton = Uri.parse('https://exaroton.com');

/// Taps on the build number that open Debug, like Android's developer
/// options.
const debugUnlockTaps = 7;

/// Whether Debug was unlocked this run. Not saved: it locks again on the
/// next launch.
bool _debugUnlocked = false;

/// Version, project links and licences. Debug is hidden behind tapping the
/// build number [debugUnlockTaps] times.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int _taps = 0;

  void _openDebug() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DebugScreen()));

  void _tapBuild() {
    if (_debugUnlocked) {
      showMessage(context, 'Debug is already on');
      return;
    }
    _taps++;
    final left = debugUnlockTaps - _taps;
    if (left <= 0) {
      setState(() => _debugUnlocked = true);
      showMessage(context, 'Debug is on');
      _openDebug();
    } else if (left <= 4) {
      showMessage(context, '$left ${left == 1 ? 'tap' : 'taps'} away from Debug');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    ListTile link(IconData icon, String title, String subtitle, Uri url) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: t.onSurfaceMuted)),
      trailing: const Icon(AppIcons.openExternal),
      onTap: () => launchUrl(url, mode: LaunchMode.externalApplication),
    );

    ListTile info(String title, String value, {VoidCallback? onTap}) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(gutter, 8, gutter, 32),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Semantics(
                image: true,
                label: 'ExaTon',
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 88,
                  height: 88,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ExaTon',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Control your exaroton servers without opening the website.',
              textAlign: TextAlign.center,
              style: TextStyle(color: t.onSurfaceMuted),
            ),
            const SectionHeader('Version'),
            CardList(
              children: [
                info('Version', appVersionName),
                info('Build', '$appVersionCode', onTap: _tapBuild),
                info('Platform', Platform.operatingSystem),
                if (_debugUnlocked)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    title: const Text('Debug'),
                    subtitle: Text('Connection checks', style: TextStyle(color: t.onSurfaceMuted)),
                    trailing: const Icon(AppIcons.next),
                    onTap: _openDebug,
                  ),
              ],
            ),
            const SectionHeader('Project'),
            CardList(
              children: [
                link(AppIcons.openExternal, 'Source code', 'github.com/RimakiTaema/ExaTon', _repo),
                link(AppIcons.history, 'Releases and changelog', 'Downloads for every platform', _releases),
                link(AppIcons.info, 'Report a problem', 'Open an issue on GitHub', _issues),
                link(AppIcons.servers, 'exaroton', 'exaroton.com', _exaroton),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: const Icon(AppIcons.textFile),
                  title: const Text('Open-source licences'),
                  trailing: const Icon(AppIcons.next),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'ExaTon',
                    applicationVersion: '$appVersionName (build $appVersionCode)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const InfoNote(
              'ExaTon is a community app and is not affiliated with exaroton. '
              "Your API tokens are kept in this device's secure storage.",
            ),
          ],
        ),
      ),
    );
  }
}
