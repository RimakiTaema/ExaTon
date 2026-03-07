// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_software.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ServerSoftware extends ServerSoftware {
  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? version;

  factory _$ServerSoftware([void Function(ServerSoftwareBuilder)? updates]) =>
      (ServerSoftwareBuilder()..update(updates))._build();

  _$ServerSoftware._({this.id, this.name, this.version}) : super._();
  @override
  ServerSoftware rebuild(void Function(ServerSoftwareBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ServerSoftwareBuilder toBuilder() => ServerSoftwareBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ServerSoftware &&
        id == other.id &&
        name == other.name &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ServerSoftware')
          ..add('id', id)
          ..add('name', name)
          ..add('version', version))
        .toString();
  }
}

class ServerSoftwareBuilder
    implements Builder<ServerSoftware, ServerSoftwareBuilder> {
  _$ServerSoftware? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  ServerSoftwareBuilder() {
    ServerSoftware._defaults(this);
  }

  ServerSoftwareBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ServerSoftware other) {
    _$v = other as _$ServerSoftware;
  }

  @override
  void update(void Function(ServerSoftwareBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ServerSoftware build() => _build();

  _$ServerSoftware _build() {
    final _$result = _$v ??
        _$ServerSoftware._(
          id: id,
          name: name,
          version: version,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
