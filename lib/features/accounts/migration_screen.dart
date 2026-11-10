import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/components.dart';
import '../../ui/motion.dart';
import '../../ui/tokens.dart';
import 'migration.dart';
import '../../ui/app_icons.dart';

/// Asks once whether to bring 1.3 logins into 1.6. Each account is checked
/// with exaroton before it is saved; 1.3's own entries are left as they are.
class MigrationScreen extends ConsumerStatefulWidget {
  const MigrationScreen({super.key, required this.accounts, required this.onDone});
  final List<LegacyAccount> accounts;
  final VoidCallback onDone;

  @override
  ConsumerState<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends ConsumerState<MigrationScreen> {
  late final Set<LegacyAccount> _selected = {...widget.accounts};
  final _results = <LegacyAccount, ImportResult>{};
  bool _running = false;
  bool _finished = false;

  int get _done => _results.values.where((r) => r.status == ImportStatus.done).length;
  int get _failed => _results.values.where((r) => r.status == ImportStatus.failed).length;

  Future<void> _import() async {
    setState(() => _running = true);
    final chosen = widget.accounts.where(_selected.contains).toList();
    for (final a in chosen) {
      _results[a] = const ImportResult(ImportStatus.waiting);
    }
    await importLegacy(ref, chosen, (a, r) {
      if (mounted) setState(() => _results[a] = r);
    });
    if (!mounted) return;
    setState(() {
      _running = false;
      _finished = true;
    });
    // Everything worked: move on by itself after the checkmarks land.
    if (_failed == 0) {
      await Future<void>.delayed(Motion.of(context, const Duration(milliseconds: 900)));
      if (mounted) widget.onDone();
    }
  }

  Future<void> _skip() async {
    await markMigrationAnswered(ref);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final n = _selected.length;
    final keychain = Platform.isMacOS ? 'Keychain' : 'Credential Manager';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(gutter),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FadeSlideIn(child: _UpgradeMark()),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    index: 1,
                    child: Text(
                      'Bring your accounts from ExaTon 1.3',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeSlideIn(
                    index: 2,
                    child: Text(
                      'We found ${widget.accounts.length} '
                      '${widget.accounts.length == 1 ? 'login' : 'logins'} saved by ExaTon 1.3 on this '
                      'device. Import ${widget.accounts.length == 1 ? 'it' : 'them'} so you don\'t have to '
                      'paste tokens again. Each token is '
                      'checked with exaroton first. Your system may ask to allow access to the $keychain.',
                      style: TextStyle(color: t.onSurfaceMuted, height: 1.45, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeSlideIn(
                    index: 3,
                    child: CardList(
                      children: [
                        for (final (i, a) in widget.accounts.indexed)
                          FadeSlideIn(
                            index: 4 + i,
                            child: _AccountRow(
                              account: a,
                              selected: _selected.contains(a),
                              result: _results[a],
                              enabled: !_running && !_finished,
                              onChanged: (on) => setState(() => on ? _selected.add(a) : _selected.remove(a)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeSlideIn(
                    index: 5,
                    child: StateSwitcher(
                      child: _finished
                          ? Column(
                              key: const ValueKey('finished'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _failed == 0
                                      ? 'All set. $_done ${_done == 1 ? 'account' : 'accounts'} imported.'
                                      : '$_done imported, $_failed could not be imported.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _failed == 0 ? t.success : t.warning,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(onPressed: widget.onDone, child: const Text('Continue')),
                              ],
                            )
                          : Column(
                              key: const ValueKey('ask'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FilledButton(
                                  onPressed: _running || n == 0 ? null : _import,
                                  child: StateSwitcher(
                                    child: _running
                                        ? SizedBox(
                                            key: const ValueKey('spin'),
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2.2, color: t.onPrimary),
                                          )
                                        : Text(n == 1 ? 'Import 1 account' : 'Import $n accounts', key: ValueKey(n)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _running ? null : _skip,
                                  child: const Text('Not now, start fresh'),
                                ),
                                Text(
                                  'You can import later from Settings > Accounts.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: t.onSurfaceMuted, fontSize: 13),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.account,
    required this.selected,
    required this.result,
    required this.enabled,
    required this.onChanged,
  });

  final LegacyAccount account;
  final bool selected;
  final ImportResult? result;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final r = result;
    final Widget trailing = switch (r?.status) {
      null => Checkbox(
        key: const ValueKey('check'),
        value: selected,
        onChanged: enabled ? (v) => onChanged(v ?? false) : null,
      ),
      ImportStatus.waiting => Icon(AppIcons.waiting, key: const ValueKey('wait'), color: t.onSurfaceMuted),
      ImportStatus.working => const SizedBox(
        key: ValueKey('work'),
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
      ImportStatus.done => const _PopIcon(key: ValueKey('done'), icon: AppIcons.done, success: true),
      ImportStatus.failed => const _PopIcon(key: ValueKey('fail'), icon: AppIcons.failed, success: false),
    };
    final subtitle = switch (r?.status) {
      ImportStatus.done => 'Imported as ${r!.message}',
      ImportStatus.failed => r!.message,
      ImportStatus.working => 'Checking with exaroton...',
      _ => null,
    };
    return MergeSemantics(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Avatar(account.email, highlight: selected && r?.status != ImportStatus.failed),
        title: Text(account.email, overflow: TextOverflow.ellipsis),
        subtitle: AnimatedSize(
          duration: Motion.of(context, Motion.medium),
          curve: Motion.emphasized,
          alignment: Alignment.topLeft,
          child: subtitle == null
              ? const SizedBox(width: double.infinity)
              : Text(subtitle, style: TextStyle(color: r?.status == ImportStatus.failed ? t.error : t.onSurfaceMuted)),
        ),
        trailing: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: StateSwitcher(child: trailing)),
        ),
        onTap: enabled ? () => onChanged(!selected) : null,
      ),
    );
  }
}

/// An icon that lands with a small overshoot.
class _PopIcon extends StatelessWidget {
  const _PopIcon({super.key, required this.icon, required this.success});
  final IconData icon;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      duration: Motion.of(context, const Duration(milliseconds: 520)),
      curve: Curves.elasticOut,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: Icon(icon, size: 26, color: success ? t.success : t.error, semanticLabel: success ? 'Imported' : 'Failed'),
    );
  }
}

/// "1.3 → 1.6" mark: the old version slides aside as the new tile lands.
class _UpgradeMark extends StatelessWidget {
  const _UpgradeMark();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.of(context, const Duration(milliseconds: 900)),
      curve: Motion.emphasized,
      builder: (context, v, _) => Row(
        children: [
          Opacity(
            opacity: 1 - 0.55 * v,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.outline, width: 1.5),
              ),
              child: Text(
                '1.3',
                style: TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Opacity(
              opacity: v,
              child: Transform.translate(
                offset: Offset(-10 * (1 - v), 0),
                child: Icon(AppIcons.send, color: t.primary),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.6 + 0.4 * Curves.easeOutBack.transform(v.clamp(0, 1)),
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: t.primary.withValues(alpha: 0.35 * v),
                    blurRadius: 24 * v,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                '1.6',
                style: TextStyle(color: t.onPrimary, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
