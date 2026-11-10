import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/components.dart';
import '../../ui/tokens.dart';
import '../../core/storage/account_store.dart';
import 'accounts.dart';
import 'add_account_screen.dart';
import '../../ui/app_icons.dart';

/// Wraps [child] in the account menu: every saved account, the active one
/// checked, and Add account. Switching reloads every list and drops open
/// sockets.
class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key, required this.child, this.position = PopupMenuPosition.under});
  final Widget child;
  final PopupMenuPosition position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final state = ref.watch(accountsProvider).value;
    final active = state?.active;
    if (active == null) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      tooltip: 'Account: ${active.name}. Switch account',
      position: position,
      onSelected: (v) async {
        if (v == '+') {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddAccountScreen(popOnDone: true)));
        } else {
          await ref.read(accountsProvider.notifier).switchTo(v);
        }
      },
      itemBuilder: (_) => [
        for (final a in state!.accounts)
          PopupMenuItem(
            value: a.id,
            child: Row(
              children: [
                Avatar(a.name, highlight: a.id == active.id, size: 30),
                const SizedBox(width: 12),
                Expanded(child: Text(a.name)),
                if (a.id == active.id) Icon(AppIcons.check, color: t.primary, semanticLabel: 'Active'),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: '+',
          child: Row(children: [Icon(AppIcons.add), SizedBox(width: 12), Text('Add account')]),
        ),
      ],
      child: child,
    );
  }
}

/// The account menu as a bottom sheet, for the phone's Account button.
Future<void> showAccountSheet(BuildContext context, WidgetRef ref) async {
  final picked = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (c) => Consumer(
      builder: (c, ref, _) {
        final t = c.tokens;
        final state = ref.watch(accountsProvider).value;
        final active = state?.active;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 12),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(gutter, 0, gutter, 8),
                child: Semantics(
                  header: true,
                  child: Text(
                    'Accounts',
                    style: Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              for (final a in state?.accounts ?? const <StoredAccount>[])
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: gutter),
                  leading: Avatar(a.name, highlight: a.id == active?.id),
                  title: Text(a.name, style: const TextStyle(fontSize: 18)),
                  subtitle: a.id == active?.id ? Text('Active', style: TextStyle(color: t.primary)) : null,
                  trailing: a.id == active?.id ? Icon(AppIcons.check, color: t.primary) : null,
                  onTap: () => Navigator.pop(c, a.id),
                ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: gutter),
                leading: const Icon(AppIcons.add),
                title: const Text('Add account', style: TextStyle(fontSize: 18)),
                onTap: () => Navigator.pop(c, '+'),
              ),
            ],
          ),
        );
      },
    ),
  );
  if (picked == null || !context.mounted) return;
  if (picked == '+') {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddAccountScreen(popOnDone: true)));
  } else if (picked != ref.read(activeAccountProvider)?.id) {
    await ref.read(accountsProvider.notifier).switchTo(picked);
  }
}
