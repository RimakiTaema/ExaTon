// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_pool.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreditPool extends CreditPool {
  @override
  final String? id;
  @override
  final String? name;
  @override
  final double? credits;
  @override
  final int? servers;
  @override
  final String? owner;
  @override
  final bool? isOwner;
  @override
  final int? members;
  @override
  final double? ownShare;
  @override
  final double? ownCredits;

  factory _$CreditPool([void Function(CreditPoolBuilder)? updates]) =>
      (CreditPoolBuilder()..update(updates))._build();

  _$CreditPool._(
      {this.id,
      this.name,
      this.credits,
      this.servers,
      this.owner,
      this.isOwner,
      this.members,
      this.ownShare,
      this.ownCredits})
      : super._();
  @override
  CreditPool rebuild(void Function(CreditPoolBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreditPoolBuilder toBuilder() => CreditPoolBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreditPool &&
        id == other.id &&
        name == other.name &&
        credits == other.credits &&
        servers == other.servers &&
        owner == other.owner &&
        isOwner == other.isOwner &&
        members == other.members &&
        ownShare == other.ownShare &&
        ownCredits == other.ownCredits;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, credits.hashCode);
    _$hash = $jc(_$hash, servers.hashCode);
    _$hash = $jc(_$hash, owner.hashCode);
    _$hash = $jc(_$hash, isOwner.hashCode);
    _$hash = $jc(_$hash, members.hashCode);
    _$hash = $jc(_$hash, ownShare.hashCode);
    _$hash = $jc(_$hash, ownCredits.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreditPool')
          ..add('id', id)
          ..add('name', name)
          ..add('credits', credits)
          ..add('servers', servers)
          ..add('owner', owner)
          ..add('isOwner', isOwner)
          ..add('members', members)
          ..add('ownShare', ownShare)
          ..add('ownCredits', ownCredits))
        .toString();
  }
}

class CreditPoolBuilder implements Builder<CreditPool, CreditPoolBuilder> {
  _$CreditPool? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  double? _credits;
  double? get credits => _$this._credits;
  set credits(double? credits) => _$this._credits = credits;

  int? _servers;
  int? get servers => _$this._servers;
  set servers(int? servers) => _$this._servers = servers;

  String? _owner;
  String? get owner => _$this._owner;
  set owner(String? owner) => _$this._owner = owner;

  bool? _isOwner;
  bool? get isOwner => _$this._isOwner;
  set isOwner(bool? isOwner) => _$this._isOwner = isOwner;

  int? _members;
  int? get members => _$this._members;
  set members(int? members) => _$this._members = members;

  double? _ownShare;
  double? get ownShare => _$this._ownShare;
  set ownShare(double? ownShare) => _$this._ownShare = ownShare;

  double? _ownCredits;
  double? get ownCredits => _$this._ownCredits;
  set ownCredits(double? ownCredits) => _$this._ownCredits = ownCredits;

  CreditPoolBuilder() {
    CreditPool._defaults(this);
  }

  CreditPoolBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _credits = $v.credits;
      _servers = $v.servers;
      _owner = $v.owner;
      _isOwner = $v.isOwner;
      _members = $v.members;
      _ownShare = $v.ownShare;
      _ownCredits = $v.ownCredits;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreditPool other) {
    _$v = other as _$CreditPool;
  }

  @override
  void update(void Function(CreditPoolBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreditPool build() => _build();

  _$CreditPool _build() {
    final _$result = _$v ??
        _$CreditPool._(
          id: id,
          name: name,
          credits: credits,
          servers: servers,
          owner: owner,
          isOwner: isOwner,
          members: members,
          ownShare: ownShare,
          ownCredits: ownCredits,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
