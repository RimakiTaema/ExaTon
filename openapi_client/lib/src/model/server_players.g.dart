// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_players.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ServerPlayers extends ServerPlayers {
  @override
  final int? max;
  @override
  final int? count;
  @override
  final BuiltList<String>? list;

  factory _$ServerPlayers([void Function(ServerPlayersBuilder)? updates]) =>
      (ServerPlayersBuilder()..update(updates))._build();

  _$ServerPlayers._({this.max, this.count, this.list}) : super._();
  @override
  ServerPlayers rebuild(void Function(ServerPlayersBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ServerPlayersBuilder toBuilder() => ServerPlayersBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ServerPlayers &&
        max == other.max &&
        count == other.count &&
        list == other.list;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, max.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, list.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ServerPlayers')
          ..add('max', max)
          ..add('count', count)
          ..add('list', list))
        .toString();
  }
}

class ServerPlayersBuilder
    implements Builder<ServerPlayers, ServerPlayersBuilder> {
  _$ServerPlayers? _$v;

  int? _max;
  int? get max => _$this._max;
  set max(int? max) => _$this._max = max;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  ListBuilder<String>? _list;
  ListBuilder<String> get list => _$this._list ??= ListBuilder<String>();
  set list(ListBuilder<String>? list) => _$this._list = list;

  ServerPlayersBuilder() {
    ServerPlayers._defaults(this);
  }

  ServerPlayersBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _max = $v.max;
      _count = $v.count;
      _list = $v.list?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ServerPlayers other) {
    _$v = other as _$ServerPlayers;
  }

  @override
  void update(void Function(ServerPlayersBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ServerPlayers build() => _build();

  _$ServerPlayers _build() {
    _$ServerPlayers _$result;
    try {
      _$result = _$v ??
          _$ServerPlayers._(
            max: max,
            count: count,
            list: _list?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'list';
        _list?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ServerPlayers', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
