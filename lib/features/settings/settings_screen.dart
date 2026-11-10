import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/models.dart';
import '../../ui/components.dart';
import '../../ui/motion.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../accounts/accounts.dart';
import '../accounts/add_account_screen.dart';
import '../accounts/migration.dart';
import '../accounts/migration_screen.dart';
import '../credits/alerts.dart';
import '../credits/estimate.dart';
import '../debug/debug_screen.dart';
import 'settings.dart';
import '../../ui/app_icons.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Theme changes are previewed here first and applied with Apply.
  ThemeSettings? _draft;

  ThemeSettings get _theme => _draft ?? ref.read(settingsProvider).theme;

  void _edit(ThemeSettings next) => setState(() => _draft = next == ref.read(settingsProvider).theme ? null : next);

  Future<void> _apply() async {
    final d = _draft;
    if (d == null) return;
    await ref.read(settingsProvider.notifier).setTheme(d);
    setState(() => _draft = null);
  }

  Future<void> _import() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Theme',
          extensions: ['json'],
          mimeTypes: ['application/json'],
          uniformTypeIdentifiers: ['public.json'],
        ),
      ],
    );
    if (file == null) return;
    try {
      final tokens = AppTokens.fromJson(await file.readAsString());
      _edit(_theme.copyWith(customDark: tokens, mode: ThemeModeSetting.dark));
      if (mounted) showMessage(context, 'Theme loaded. Check the preview, then Apply.');
    } on ThemeImportException catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Theme not imported'),
          content: Text(e.message),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
        ),
      );
    }
  }

  Future<void> _export() async {
    final json = _theme.tokensFor(Brightness.dark).toJson();
    if (Platform.isAndroid || Platform.isIOS) {
      await Clipboard.setData(ClipboardData(text: json));
      if (mounted) showMessage(context, 'Theme JSON copied to the clipboard');
      return;
    }
    final loc = await getSaveLocation(suggestedName: 'exaton-theme.json');
    if (loc == null) return;
    await File(loc.path).writeAsString(json);
    if (mounted) showMessage(context, 'Theme exported');
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(settingsProvider);
    final theme = _draft ?? saved.theme;
    final t = context.tokens;
    final label = TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w700, fontSize: 16);

    Widget heading(String s) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Semantics(header: true, child: Text(s, style: label)),
    );

    final previewBrightness = switch (theme.mode) {
      ThemeModeSetting.light => Brightness.light,
      ThemeModeSetting.dark => Brightness.dark,
      ThemeModeSetting.system => MediaQuery.platformBrightnessOf(context),
    };
    final previewTokens = theme.tokensFor(previewBrightness);

    return ListView(
      padding: const EdgeInsets.fromLTRB(gutter, 16, gutter, 40),
      children: [
        Semantics(header: true, child: Text('Settings', style: Theme.of(context).textTheme.headlineLarge)),
        heading('Theme'),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ThemeModeSetting>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ThemeModeSetting.light, label: Text('Light')),
              ButtonSegment(value: ThemeModeSetting.dark, label: Text('Dark')),
              ButtonSegment(value: ThemeModeSetting.system, label: Text('System')),
            ],
            selected: {theme.mode},
            onSelectionChanged: (s) => _edit(theme.copyWith(mode: s.first)),
          ),
        ),
        heading('Accent color'),
        if (theme.customDark != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text('A custom theme is in use for Dark.', style: TextStyle(color: t.onSurfaceMuted)),
                ),
                TextButton(onPressed: () => _edit(theme.copyWith(clearCustom: true)), child: const Text('Remove')),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 520 ? 6 : 3;
            final w = (c.maxWidth - (cols - 1) * 12) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final a in Accent.values)
                  SizedBox(
                    width: w,
                    child: _AccentTile(
                      accent: a,
                      selected: theme.accent == a,
                      color: previewBrightness == Brightness.dark ? a.onDark : a.onLight,
                      onTap: () => _edit(theme.copyWith(accent: a)),
                    ),
                  ),
              ],
            );
          },
        ),
        heading('Contrast'),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ContrastSetting>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ContrastSetting.standard, label: Text('Standard')),
              ButtonSegment(value: ContrastSetting.high, label: Text('High')),
            ],
            selected: {theme.contrast},
            onSelectionChanged: (s) => _edit(theme.copyWith(contrast: s.first)),
          ),
        ),
        heading('Live preview'),
        Theme(
          data: buildTheme(previewTokens, previewBrightness, highContrast: theme.contrast == ContrastSetting.high),
          child: Builder(
            builder: (context) => AppCard(
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Survival SMP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        StatusLabel(ServerStatus.online, suffix: '4 / 20'),
                      ],
                    ),
                  ),
                  FilledButton(onPressed: () {}, child: const Text('Manage')),
                ],
              ),
            ),
          ),
        ),
        // Apply bar grows in when the preview differs from the saved theme.
        AnimatedSize(
          duration: Motion.of(context, Motion.medium),
          curve: Motion.emphasized,
          alignment: Alignment.topCenter,
          child: _draft == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => setState(() => _draft = null), child: const Text('Reset')),
                      const SizedBox(width: 8),
                      FilledButton(onPressed: _apply, child: const Text('Apply theme')),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),
        CardList(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              title: const Text('Import theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              trailing: const Icon(AppIcons.next),
              onTap: _import,
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              title: const Text('Export theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              trailing: const Icon(AppIcons.next),
              onTap: _export,
            ),
          ],
        ),
        const _CreditSettings(),
        const _QuickCommands(),
        const _Accounts(),
      ],
    );
  }
}

class _AccentTile extends StatelessWidget {
  const _AccentTile({required this.accent, required this.selected, required this.color, required this.onTap});
  final Accent accent;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      selected: selected,
      button: true,
      label: '${accent.label} accent',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.medium),
        curve: Motion.emphasized,
        decoration: BoxDecoration(
          color: selected ? Color.alphaBlend(color.withValues(alpha: 0.08), t.surface) : t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : t.outline, width: selected ? 2 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  AnimatedScale(
                    scale: selected ? 1.12 : 1,
                    duration: Motion.of(context, Motion.medium),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: StateSwitcher(
                        child: selected
                            ? Icon(AppIcons.check, key: const ValueKey(true), size: 15, color: t.background)
                            : const SizedBox.shrink(key: ValueKey(false)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      accent.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

class _CreditSettings extends ConsumerWidget {
  const _CreditSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Credits'),
        Text(
          'Time-left estimate',
          style: TextStyle(color: t.onSurfaceMuted, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SegmentedButton<EstimateMethod>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: EstimateMethod.runningServers, label: Text('Running servers')),
            ButtonSegment(value: EstimateMethod.recentUsage, label: Text('Recent usage')),
          ],
          selected: {s.estimateMethod},
          onSelectionChanged: (v) => n.update((x) => x.copyWith(estimateMethod: v.first)),
        ),
        const SizedBox(height: 8),
        Text(
          s.estimateMethod == EstimateMethod.runningServers
              ? 'Adds up 1 credit per GB of RAM per hour for each running server. Falls back to Recent usage '
                    'when a server\'s RAM is unknown. Storage (10 credits per server per month) is not included.'
              : 'Measures how fast the balance fell over the last 6 hours, ignoring deposits. '
                    'Needs at least 30 minutes of samples taken while the app is open.',
          style: TextStyle(color: t.onSurfaceMuted, height: 1.4),
        ),
        const SizedBox(height: 16),
        CardList(
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              title: const Text('Low credit alerts'),
              subtitle: Text(
                Platform.isAndroid ? 'Checked about once an hour in the background' : 'Checked while the app is open',
              ),
              value: s.alertsEnabled,
              onChanged: (on) async {
                if (on) await CreditAlerts.instance.requestPermission();
                await n.update((x) => x.copyWith(alertsEnabled: on));
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              title: const Text('Alert when time left is under'),
              trailing: DropdownButton<int>(
                value: s.alertThresholdDays,
                underline: const SizedBox.shrink(),
                items: [
                  for (final d in const [1, 2, 3, 5, 7, 14, 30]) DropdownMenuItem(value: d, child: Text('$d days')),
                  if (!const [1, 2, 3, 5, 7, 14, 30].contains(s.alertThresholdDays))
                    DropdownMenuItem(value: s.alertThresholdDays, child: Text('${s.alertThresholdDays} days')),
                ],
                onChanged: (d) => d == null ? null : n.update((x) => x.copyWith(alertThresholdDays: d)),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              title: const Text('Also alert under a credit floor'),
              subtitle: Text(s.creditFloor == null ? 'Off' : '${formatCredits(s.creditFloor!)} credits'),
              trailing: const Icon(AppIcons.next),
              onTap: () async {
                final c = TextEditingController(text: s.creditFloor?.toString() ?? '');
                final v = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Credit floor'),
                    content: TextField(
                      controller: c,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Leave empty for off', suffixText: 'credits'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Save')),
                    ],
                  ),
                );
                c.dispose();
                if (v == null) return;
                final f = double.tryParse(v.trim());
                await n.update((x) => f == null ? x.copyWith(clearCreditFloor: true) : x.copyWith(creditFloor: f));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickCommands extends ConsumerWidget {
  const _QuickCommands();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cmds = ref.watch(settingsProvider.select((s) => s.quickCommands));
    final n = ref.read(settingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          'Console quick commands',
          trailing: TextButton(
            onPressed: () => n.update((s) => s.copyWith(quickCommands: defaultQuickCommands)),
            child: const Text('Reset'),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in cmds)
              InputChip(
                label: Text(c),
                onDeleted: () => n.update((s) => s.copyWith(quickCommands: [...s.quickCommands]..remove(c))),
                deleteButtonTooltipMessage: 'Remove $c',
              ),
            ActionChip(
              avatar: const Icon(AppIcons.add, size: 18),
              label: const Text('Add'),
              onPressed: () async {
                final c = TextEditingController();
                final v = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Quick command'),
                    content: TextField(
                      controller: c,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'e.g. weather clear'),
                      onSubmitted: (v) => Navigator.pop(ctx, v),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Add')),
                    ],
                  ),
                );
                c.dispose();
                final cmd = v?.trim();
                if (cmd == null || cmd.isEmpty) return;
                await n.update((s) => s.copyWith(quickCommands: [...s.quickCommands.where((x) => x != cmd), cmd]));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _Accounts extends ConsumerWidget {
  const _Accounts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountsProvider).value;
    final legacy = ref.watch(legacyAccountsProvider).value ?? const [];
    final t = context.tokens;
    if (state == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Accounts'),
        CardList(
          children: [
            for (final a in state.accounts)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Avatar(a.name, highlight: a.id == state.active?.id),
                title: Text(a.name),
                subtitle: a.id == state.active?.id ? Text('Active', style: TextStyle(color: t.primary)) : null,
                onTap: a.id == state.active?.id ? null : () => ref.read(accountsProvider.notifier).switchTo(a.id),
                trailing: IconButton(
                  tooltip: 'Remove ${a.name}',
                  icon: const Icon(AppIcons.signOut),
                  onPressed: () async {
                    final ok = await confirm(
                      context,
                      title: 'Remove ${a.name}?',
                      body: 'The token is deleted from this device. Your exaroton account is not changed.',
                      action: 'Remove',
                      destructive: true,
                    );
                    if (ok) await ref.read(accountsProvider.notifier).remove(a.id);
                  },
                ),
              ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: const Icon(AppIcons.add),
              title: const Text('Add account'),
              onTap: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const AddAccountScreen(popOnDone: true))),
            ),
            if (legacy.isNotEmpty)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: const Icon(AppIcons.importLegacy),
                title: const Text('Import from ExaTon 1.5'),
                subtitle: Text('${legacy.length} ${legacy.length == 1 ? 'login' : 'logins'} found on this device'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) => MigrationScreen(accounts: legacy, onDone: () => Navigator.of(c).pop()),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        CardList(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              title: const Text('Debug', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              subtitle: const Text('Connection checks and version'),
              trailing: const Icon(AppIcons.next),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DebugScreen())),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'ExaTon 1.6 - not affiliated with exaroton',
          textAlign: TextAlign.center,
          style: TextStyle(color: t.onSurfaceMuted),
        ),
      ],
    );
  }
}
