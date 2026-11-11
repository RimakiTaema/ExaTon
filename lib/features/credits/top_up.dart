import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../ui/components.dart';
import '../../ui/motion.dart';
import '../../ui/toast.dart';
import '../../ui/tokens.dart';
import 'credits.dart';
import '../../ui/app_icons.dart';

/// exaroton's own pages. The API has no deposit endpoint, so top-ups
/// happen on the website.
final topUpAccountUrl = Uri.parse('https://exaroton.com/buy/');
final topUpPoolsUrl = Uri.parse('https://exaroton.com/pools/');

@immutable
class TopUpTarget {
  const TopUpTarget.account() : url = null, poolName = null;
  const TopUpTarget.pool(this.poolName) : url = null;

  final Uri? url;

  /// Set for a pool deposit.
  final String? poolName;

  Uri get resolved => url ?? (poolName == null ? topUpAccountUrl : topUpPoolsUrl);
  String get title => poolName == null ? 'Top up credits' : 'Deposit to $poolName';
}

/// Hosts that refuse to sign in inside an embedded webview. Navigations to
/// them leave the popup for the system browser.
const handOffHosts = {'accounts.google.com'};

bool mustOpenInBrowser(Uri u) => handOffHosts.contains(u.host);

/// Refreshes balances once, the next time the app returns to the
/// foreground (after the user finishes in the browser).
void refreshCreditsOnResume(ProviderContainer container) {
  late final AppLifecycleListener listener;
  listener = AppLifecycleListener(
    onResume: () {
      refreshCredits(container.invalidate);
      listener.dispose();
    },
  );
}

/// Opens a top-up. Overridable in tests.
typedef TopUpLauncher = Future<void> Function(BuildContext context, TopUpTarget target);

final topUpLauncherProvider = Provider<TopUpLauncher>((ref) => showTopUp);

/// Whether this platform gets the in-app popup. webview_flutter covers
/// Android, iOS and macOS; Windows and Linux open the default browser.
bool get inAppTopUpSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

/// Shows exaroton's top-up page in a popup: a sheet on phones, a dialog on
/// wide windows. When it closes, balances refresh in case credits landed.
Future<void> showTopUp(BuildContext context, TopUpTarget target) async {
  final container = ProviderScope.containerOf(context, listen: false);
  if (!inAppTopUpSupported) {
    await launchUrl(target.resolved, mode: LaunchMode.externalApplication);
    if (context.mounted) showMessage(context, 'Opened exaroton in your browser. Balances refresh when you come back.');
    refreshCreditsOnResume(container);
    return;
  }

  final compact = WindowSize.of(context) == WindowSize.compact;
  final page = TopUpPage(target: target);
  String? result;
  if (compact) {
    result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => FractionallySizedBox(heightFactor: 0.94, child: page),
    );
  } else {
    result = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close top up',
      barrierColor: context.tokens.scrim,
      transitionDuration: Motion.of(context, Motion.long),
      pageBuilder: (_, _, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 820),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Material(borderRadius: BorderRadius.circular(22), clipBehavior: Clip.antiAlias, child: page),
          ),
        ),
      ),
      // Rises and fades in, settling with a slight scale.
      transitionBuilder: (_, a, _, child) {
        final t = CurvedAnimation(parent: a, curve: Motion.emphasized, reverseCurve: Curves.easeIn);
        return FadeTransition(
          opacity: t,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(t),
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(t),
              child: child,
            ),
          ),
        );
      },
    );
  }
  // A hand-off to the browser refreshes on return instead.
  if (result == 'handoff') return;
  refreshCredits(container.invalidate);
  if (context.mounted) showMessage(context, 'Refreshing balances');
}

/// The popup's content: an address bar that always shows the real host
/// (so the user knows where they enter payment details), progress, and an
/// escape hatch to the system browser for providers that refuse webviews.
class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key, required this.target});
  final TopUpTarget target;

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  late final WebViewController _web;
  late Uri _current = widget.target.resolved;
  double _progress = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p / 100);
          },
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _loading = true;
                _error = null;
                _current = Uri.tryParse(url) ?? _current;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onUrlChange: (c) {
            final u = c.url == null ? null : Uri.tryParse(c.url!);
            if (u != null && mounted) setState(() => _current = u);
          },
          onWebResourceError: (e) {
            if (e.isForMainFrame ?? true) {
              if (mounted) setState(() => _error = e.description);
            }
          },
          // Only secure pages load inside the app. Anything else (mailto:,
          // app links, plain http) goes to the system.
          onNavigationRequest: (req) {
            final u = Uri.tryParse(req.url);
            if (u == null) return NavigationDecision.prevent;
            if (mustOpenInBrowser(u)) {
              _handOff(u);
              return NavigationDecision.prevent;
            }
            if (u.scheme == 'https' || u.scheme == 'about') return NavigationDecision.navigate;
            launchUrl(u, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(widget.target.resolved);
  }

  bool get _onExaroton => _current.host == 'exaroton.com' || _current.host.endsWith('.exaroton.com');

  Future<void> _openInBrowser() async {
    refreshCreditsOnResume(ProviderScope.containerOf(context, listen: false));
    await launchUrl(_current, mode: LaunchMode.externalApplication);
  }

  /// Google sign-in refuses embedded webviews: close the popup and finish
  /// in the system browser.
  Future<void> _handOff(Uri u) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final toaster = Toaster.of(context);
    refreshCreditsOnResume(container);
    Navigator.of(context).maybePop('handoff');
    await launchUrl(u, mode: LaunchMode.externalApplication);
    toaster?.show('Google sign-in opens in your browser. Balances refresh when you come back.');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final secure = _current.scheme == 'https';

    return Material(
      color: t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Expanded(child: Text(widget.target.title, style: Theme.of(context).textTheme.titleLarge)),
                IconButton(tooltip: 'Reload', icon: const Icon(AppIcons.refresh), onPressed: () => _web.reload()),
                IconButton(
                  tooltip: 'Open in browser',
                  icon: const Icon(AppIcons.openExternal),
                  onPressed: _openInBrowser,
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(AppIcons.close),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          // Address bar: lock + host, tinted when leaving exaroton (sign-in
          // or a payment provider), so the destination is never hidden.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: AnimatedContainer(
              duration: Motion.of(context, Motion.medium),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: t.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _onExaroton ? t.outline : t.warning.withValues(alpha: 0.6)),
              ),
              child: Semantics(
                label: '${secure ? 'Secure' : 'Not secure'} page on ${_current.host}',
                excludeSemantics: true,
                child: Row(
                  children: [
                    Icon(secure ? AppIcons.secure : AppIcons.insecure, size: 16, color: secure ? t.success : t.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StateSwitcher(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _current.host,
                          key: ValueKey(_current.host),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    if (!_onExaroton) Text('Outside exaroton', style: TextStyle(color: t.warning, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _loading ? 1 : 0,
            duration: Motion.of(context, Motion.medium),
            child: LinearProgressIndicator(value: _progress == 0 ? null : _progress, minHeight: 2),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: WebViewWidget(controller: _web)),
                if (_error != null)
                  Positioned.fill(
                    child: ColoredBox(
                      color: t.surface,
                      child: ErrorPanel(
                        'Could not load the page: $_error',
                        onRetry: () {
                          setState(() => _error = null);
                          _web.reload();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                Icon(AppIcons.info, size: 16, color: t.onSurfaceMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You sign in and pay on exaroton\'s site. ExaTon never sees your password or '
                    'payment details. If sign-in or payment will not load here, use Open in browser.',
                    style: TextStyle(color: t.onSurfaceMuted, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Top up" button used on the credit screens.
class TopUpButton extends ConsumerWidget {
  const TopUpButton({super.key, this.target = const TopUpTarget.account(), this.compact = false});
  final TopUpTarget target;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void open() => ref.read(topUpLauncherProvider)(context, target);
    if (compact) {
      return IconButton.filledTonal(tooltip: target.title, icon: const Icon(AppIcons.topUp), onPressed: open);
    }
    return FilledButton.tonalIcon(
      onPressed: open,
      icon: const Icon(AppIcons.topUp, size: 20),
      label: Text(target.poolName == null ? 'Top up' : 'Deposit'),
    );
  }
}
