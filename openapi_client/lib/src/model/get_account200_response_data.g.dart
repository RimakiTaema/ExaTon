// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_account200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAccount200ResponseData extends GetAccount200ResponseData {
  @override
  final String? name;
  @override
  final String? email;
  @override
  final bool? verified;
  @override
  final double? credits;

  factory _$GetAccount200ResponseData(
          [void Function(GetAccount200ResponseDataBuilder)? updates]) =>
      (GetAccount200ResponseDataBuilder()..update(updates))._build();

  _$GetAccount200ResponseData._(
      {this.name, this.email, this.verified, this.credits})
      : super._();
  @override
  GetAccount200ResponseData rebuild(
          void Function(GetAccount200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAccount200ResponseDataBuilder toBuilder() =>
      GetAccount200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAccount200ResponseData &&
        name == other.name &&
        email == other.email &&
        verified == other.verified &&
        credits == other.credits;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, verified.hashCode);
    _$hash = $jc(_$hash, credits.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAccount200ResponseData')
          ..add('name', name)
          ..add('email', email)
          ..add('verified', verified)
          ..add('credits', credits))
        .toString();
  }
}

class GetAccount200ResponseDataBuilder
    implements
        Builder<GetAccount200ResponseData, GetAccount200ResponseDataBuilder> {
  _$GetAccount200ResponseData? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  bool? _verified;
  bool? get verified => _$this._verified;
  set verified(bool? verified) => _$this._verified = verified;

  double? _credits;
  double? get credits => _$this._credits;
  set credits(double? credits) => _$this._credits = credits;

  GetAccount200ResponseDataBuilder() {
    GetAccount200ResponseData._defaults(this);
  }

  GetAccount200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _email = $v.email;
      _verified = $v.verified;
      _credits = $v.credits;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAccount200ResponseData other) {
    _$v = other as _$GetAccount200ResponseData;
  }

  @override
  void update(void Function(GetAccount200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAccount200ResponseData build() => _build();

  _$GetAccount200ResponseData _build() {
    final _$result = _$v ??
        _$GetAccount200ResponseData._(
          name: name,
          email: email,
          verified: verified,
          credits: credits,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
