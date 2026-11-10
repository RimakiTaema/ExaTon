import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../../core/exaroton/models.dart';
import '../../core/storage/account_store.dart';

@immutable
class AccountsState {
  const AccountsState({required this.accounts, required this.activeId});
  final List<StoredAccount> accounts;
  final String? activeId;

  StoredAccount? get active {
    for (final a in accounts) {
      if (a.id == activeId) return a;
    }
    return accounts.isEmpty ? null : accounts.first;
  }
}

final accountStoreProvider = Provider<AccountStore>((ref) => AccountStore());

/// Builds a client for a token. Overridable in tests.
final clientFactoryProvider = Provider<ExarotonClient Function(String token)>((ref) => ExarotonClient.new);

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, AccountsState>(AccountsNotifier.new);

class AccountsNotifier extends AsyncNotifier<AccountsState> {
  AccountStore get _store => ref.read(accountStoreProvider);

  @override
  Future<AccountsState> build() async {
    final list = await _store.load();
    return AccountsState(accounts: list, activeId: await _store.activeId());
  }

  /// Checks the token against `GET /account/`, then saves it. Throws
  /// [ExarotonException] for a bad token.
  Future<StoredAccount> add(String token) async {
    final trimmed = token.trim();
    final client = ref.read(clientFactoryProvider)(trimmed);
    final Account info;
    try {
      info = await client.getAccount();
    } finally {
      client.close();
    }
    final current = state.value?.accounts ?? const [];
    final dupe = current.where((a) => a.token == trimmed);
    if (dupe.isNotEmpty) {
      await switchTo(dupe.first.id);
      return dupe.first;
    }
    final saved = await _store.add(info.name.isEmpty ? 'Account' : info.name, trimmed);
    await _store.setActive(saved.id);
    state = AsyncData(AccountsState(accounts: [...current, saved], activeId: saved.id));
    return saved;
  }

  /// Switching reloads every list and drops open sockets, because those
  /// providers depend on [activeAccountProvider].
  Future<void> switchTo(String id) async {
    await _store.setActive(id);
    final s = state.value;
    if (s != null) state = AsyncData(AccountsState(accounts: s.accounts, activeId: id));
  }

  Future<void> remove(String id) async {
    await _store.remove(id);
    state = AsyncData(await build());
  }
}

final activeAccountProvider = Provider<StoredAccount?>((ref) => ref.watch(accountsProvider).value?.active);

/// The client for the active account. Recreated (and the old one closed)
/// when the account changes.
final clientProvider = Provider<ExarotonClient?>((ref) {
  final token = ref.watch(activeAccountProvider.select((a) => a?.token));
  if (token == null) return null;
  final client = ref.watch(clientFactoryProvider)(token);
  ref.onDispose(client.close);
  return client;
});

ExarotonClient requireClient(Ref ref) {
  final c = ref.watch(clientProvider);
  if (c == null) throw StateError('No account');
  return c;
}

final accountInfoProvider = FutureProvider<Account>((ref) => requireClient(ref).getAccount());
