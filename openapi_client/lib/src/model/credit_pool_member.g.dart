// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_pool_member.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreditPoolMember extends CreditPoolMember {
  @override
  final String? account;
  @override
  final String? name;
  @override
  final double? share;
  @override
  final double? credits;
  @override
  final bool? isOwner;

  factory _$CreditPoolMember(
          [void Function(CreditPoolMemberBuilder)? updates]) =>
      (CreditPoolMemberBuilder()..update(updates))._build();

  _$CreditPoolMember._(
      {this.account, this.name, this.share, this.credits, this.isOwner})
      : super._();
  @override
  CreditPoolMember rebuild(void Function(CreditPoolMemberBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreditPoolMemberBuilder toBuilder() =>
      CreditPoolMemberBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreditPoolMember &&
        account == other.account &&
        name == other.name &&
        share == other.share &&
        credits == other.credits &&
        isOwner == other.isOwner;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, account.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, share.hashCode);
    _$hash = $jc(_$hash, credits.hashCode);
    _$hash = $jc(_$hash, isOwner.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreditPoolMember')
          ..add('account', account)
          ..add('name', name)
          ..add('share', share)
          ..add('credits', credits)
          ..add('isOwner', isOwner))
        .toString();
  }
}

class CreditPoolMemberBuilder
    implements Builder<CreditPoolMember, CreditPoolMemberBuilder> {
  _$CreditPoolMember? _$v;

  String? _account;
  String? get account => _$this._account;
  set account(String? account) => _$this._account = account;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  double? _share;
  double? get share => _$this._share;
  set share(double? share) => _$this._share = share;

  double? _credits;
  double? get credits => _$this._credits;
  set credits(double? credits) => _$this._credits = credits;

  bool? _isOwner;
  bool? get isOwner => _$this._isOwner;
  set isOwner(bool? isOwner) => _$this._isOwner = isOwner;

  CreditPoolMemberBuilder() {
    CreditPoolMember._defaults(this);
  }

  CreditPoolMemberBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _account = $v.account;
      _name = $v.name;
      _share = $v.share;
      _credits = $v.credits;
      _isOwner = $v.isOwner;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreditPoolMember other) {
    _$v = other as _$CreditPoolMember;
  }

  @override
  void update(void Function(CreditPoolMemberBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreditPoolMember build() => _build();

  _$CreditPoolMember _build() {
    final _$result = _$v ??
        _$CreditPoolMember._(
          account: account,
          name: name,
          share: share,
          credits: credits,
          isOwner: isOwner,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
