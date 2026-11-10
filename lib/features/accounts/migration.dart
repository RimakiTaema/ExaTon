import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/exaroton/client.dart';
import '../settings/settings.dart';
import 'accounts.dart';

/// Keychain service ExaTon 1.5 (Tauri) saved tokens under.
const legacyService = 'net.rimaki.exatonext';

@immutable
class LegacyAccount {
  const LegacyAccount({required this.email, required this.token});
  final String email;
  final String token;

  @override
  String toString() => 'LegacyAccount($email)'; // Never print the token.
}

/// Finds 1.5 logins. 1.5 kept its account list in web view storage that 1.6
/// cannot read, but every token is in the OS credential store keyed by
/// email, so listing the service is enough:
/// - macOS: login keychain generic passwords (native channel).
/// - Windows: Credential Manager "{email}.net.rimaki.exatonext" (native).
/// - Linux: 1.5 used the kernel keyring, which does not survive a logout,
///   so there is nothing reliable to read.
/// - Android and iOS: 1.5 was not released there.
class LegacyTokenSource {
  const LegacyTokenSource([this._channel = const MethodChannel('exaton/legacy')]);
  final MethodChannel _channel;

  Future<List<LegacyAccount>> find() async {
    if (kIsWeb || !(Platform.isMacOS || Platform.isWindows)) return const [];
    try {
      // The OS may show an "allow access" prompt per item. If it is left
      // unanswered, give up rather than hold the app on a spinner; the user
      // can import later from Settings.
      final raw = await _channel
          .invokeListMethod<Map<Object?, Object?>>('listTokens', {'service': legacyService})
          .timeout(const Duration(seconds: 45), onTimeout: () => const []);
      final seen = <String>{};
      return [
        for (final e in raw ?? const <Map<Object?, Object?>>[])
          if (e['email'] is String && e['token'] is String && seen.add(e['token'] as String))
            LegacyAccount(email: e['email'] as String, token: (e['token'] as String).trim()),
      ];
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }
}

final legacyTokenSourceProvider = Provider<LegacyTokenSource>((ref) => const LegacyTokenSource());

/// 1.5 logins not yet in 1.6. Empty once imported or dismissed.
final legacyAccountsProvider = FutureProvider<List<LegacyAccount>>((ref) async {
  final state = await ref.watch(accountsProvider.future);
  final known = state.accounts.map((a) => a.token).toSet();
  final found = await ref.read(legacyTokenSourceProvider).find();
  return found.where((l) => !known.contains(l.token)).toList();
});

/// Whether to ask on startup: something was found and the user has not
/// answered yet. Settings can still import later.
final migrationPromptProvider = FutureProvider<List<LegacyAccount>>((ref) async {
  final pending = await ref.watch(legacyAccountsProvider.future);
  if (pending.isEmpty) return const [];
  final answered = (await ref.read(databaseProvider).readJson('migration'))?['answered'] == true;
  return answered ? const [] : pending;
});

enum ImportStatus { waiting, working, done, failed }

@immutable
class ImportResult {
  const ImportResult(this.status, [this.message]);
  final ImportStatus status;
  final String? message;
}

Future<void> markMigrationAnswered(WidgetRef ref) async {
  await ref.read(databaseProvider).writeJson('migration', {'answered': true, 'at': DateTime.now().toIso8601String()});
  ref.invalidate(migrationPromptProvider);
}

/// Imports each login by checking its token with exaroton and saving it in
/// 1.6's secure storage. 1.5's entries are left untouched.
Future<void> importLegacy(
  WidgetRef ref,
  List<LegacyAccount> accounts,
  void Function(LegacyAccount, ImportResult) onProgress,
) async {
  final notifier = ref.read(accountsProvider.notifier);
  String? firstId;
  for (final a in accounts) {
    onProgress(a, const ImportResult(ImportStatus.working));
    try {
      final saved = await notifier.add(a.token);
      firstId ??= saved.id;
      onProgress(a, ImportResult(ImportStatus.done, saved.name));
    } on ExarotonException catch (e) {
      onProgress(a, ImportResult(ImportStatus.failed, e.isUnauthorized ? 'Token no longer valid' : e.message));
    } catch (e) {
      onProgress(a, ImportResult(ImportStatus.failed, '$e'));
    }
  }
  if (firstId != null) await notifier.switchTo(firstId);
  await markMigrationAnswered(ref);
  ref.invalidate(legacyAccountsProvider);
}
