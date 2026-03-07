// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Server extends Server {
  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? address;
  @override
  final String? motd;
  @override
  final ServerStatus? status;
  @override
  final String? host;
  @override
  final int? port;
  @override
  final ServerPlayers? players;
  @override
  final ServerSoftware? software;
  @override
  final bool? shared;

  factory _$Server([void Function(ServerBuilder)? updates]) =>
      (ServerBuilder()..update(updates))._build();

  _$Server._(
      {this.id,
      this.name,
      this.address,
      this.motd,
      this.status,
      this.host,
      this.port,
      this.players,
      this.software,
      this.shared})
      : super._();
  @override
  Server rebuild(void Function(ServerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ServerBuilder toBuilder() => ServerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Server &&
        id == other.id &&
        name == other.name &&
        address == other.address &&
        motd == other.motd &&
        status == other.status &&
        host == other.host &&
        port == other.port &&
        players == other.players &&
        software == other.software &&
        shared == other.shared;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, motd.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, host.hashCode);
    _$hash = $jc(_$hash, port.hashCode);
    _$hash = $jc(_$hash, players.hashCode);
    _$hash = $jc(_$hash, software.hashCode);
    _$hash = $jc(_$hash, shared.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Server')
          ..add('id', id)
          ..add('name', name)
          ..add('address', address)
          ..add('motd', motd)
          ..add('status', status)
          ..add('host', host)
          ..add('port', port)
          ..add('players', players)
          ..add('software', software)
          ..add('shared', shared))
        .toString();
  }
}

class ServerBuilder implements Builder<Server, ServerBuilder> {
  _$Server? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _motd;
  String? get motd => _$this._motd;
  set motd(String? motd) => _$this._motd = motd;

  ServerStatus? _status;
  ServerStatus? get status => _$this._status;
  set status(ServerStatus? status) => _$this._status = status;

  String? _host;
  String? get host => _$this._host;
  set host(String? host) => _$this._host = host;

  int? _port;
  int? get port => _$this._port;
  set port(int? port) => _$this._port = port;

  ServerPlayersBuilder? _players;
  ServerPlayersBuilder get players =>
      _$this._players ??= ServerPlayersBuilder();
  set players(ServerPlayersBuilder? players) => _$this._players = players;

  ServerSoftwareBuilder? _software;
  ServerSoftwareBuilder get software =>
      _$this._software ??= ServerSoftwareBuilder();
  set software(ServerSoftwareBuilder? software) => _$this._software = software;

  bool? _shared;
  bool? get shared => _$this._shared;
  set shared(bool? shared) => _$this._shared = shared;

  ServerBuilder() {
    Server._defaults(this);
  }

  ServerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _address = $v.address;
      _motd = $v.motd;
      _status = $v.status;
      _host = $v.host;
      _port = $v.port;
      _players = $v.players?.toBuilder();
      _software = $v.software?.toBuilder();
      _shared = $v.shared;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Server other) {
    _$v = other as _$Server;
  }

  @override
  void update(void Function(ServerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Server build() => _build();

  _$Server _build() {
    _$Server _$result;
    try {
      _$result = _$v ??
          _$Server._(
            id: id,
            name: name,
            address: address,
            motd: motd,
            status: status,
            host: host,
            port: port,
            players: _players?.build(),
            software: _software?.build(),
            shared: shared,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'players';
        _players?.build();
        _$failedField = 'software';
        _software?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Server', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
