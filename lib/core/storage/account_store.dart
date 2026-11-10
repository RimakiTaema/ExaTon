import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A saved exaroton account. The token is only ever held in memory and in
/// the OS secure store.
class StoredAccount {
  const StoredAccount({required this.id, required this.name, required this.token});
  final String id;
  final String name;
  final String token;

  StoredAccount copyWith({String? name}) => StoredAccount(id: id, name: name ?? this.name, token: token);

  /// Avatar initial.
  String get initial => name.isEmpty ? '?' : name.characters1.toUpperCase();

  @override
  String toString() => 'StoredAccount($id, $name)'; // Never print the token.
}

extension on String {
  String get characters1 => runes.isEmpty ? '' : String.fromCharCode(runes.first);
}

/// Tokens in Keychain, Keystore, Credential Manager or libsecret via
/// flutter_secure_storage. Never in preferences or logs.
class AccountStore {
  AccountStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            // The login keychain works without the keychain-access-groups
            // entitlement, which unsigned and ad-hoc builds cannot have
            // (the data protection keychain fails there with -34018).
            mOptions: MacOsOptions(
              accessibility: KeychainAccessibility.first_unlock,
              usesDataProtectionKeychain: false,
            ),
          );

  final FlutterSecureStorage _storage;
  static const _indexKey = 'exaton.accounts';
  static const _activeKey = 'exaton.active';
  static String _tokenKey(String id) => 'exaton.token.$id';

  Future<List<StoredAccount>> load() async {
    final raw = await _storage.read(key: _indexKey);
    if (raw == null) return [];
    final List<dynamic> index;
    try {
      index = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }
    final out = <StoredAccount>[];
    for (final e in index.whereType<Map>()) {
      final id = e['id'] as String?;
      if (id == null) continue;
      final token = await _storage.read(key: _tokenKey(id));
      if (token == null) continue;
      out.add(StoredAccount(id: id, name: (e['name'] as String?) ?? 'Account', token: token));
    }
    return out;
  }

  Future<StoredAccount> add(String name, String token) async {
    final id = _newId();
    await _storage.write(key: _tokenKey(id), value: token);
    final list = await load();
    await _writeIndex([...list, StoredAccount(id: id, name: name, token: token)]);
    return StoredAccount(id: id, name: name, token: token);
  }

  Future<void> rename(String id, String name) async {
    final list = await load();
    await _writeIndex([for (final a in list) a.id == id ? a.copyWith(name: name) : a]);
  }

  Future<void> remove(String id) async {
    await _storage.delete(key: _tokenKey(id));
    final list = await load();
    await _writeIndex(list.where((a) => a.id != id).toList());
    if (await activeId() == id) await _storage.delete(key: _activeKey);
  }

  Future<String?> activeId() => _storage.read(key: _activeKey);

  Future<void> setActive(String id) => _storage.write(key: _activeKey, value: id);

  Future<void> _writeIndex(List<StoredAccount> list) => _storage.write(
    key: _indexKey,
    value: jsonEncode([
      for (final a in list) {'id': a.id, 'name': a.name},
    ]),
  );

  static String _newId() {
    final r = Random.secure();
    return List.generate(16, (_) => r.nextInt(16).toRadixString(16)).join();
  }
}
