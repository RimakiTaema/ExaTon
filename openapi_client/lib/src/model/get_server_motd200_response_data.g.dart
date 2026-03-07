// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_server_motd200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetServerMotd200ResponseData extends GetServerMotd200ResponseData {
  @override
  final String? motd;

  factory _$GetServerMotd200ResponseData(
          [void Function(GetServerMotd200ResponseDataBuilder)? updates]) =>
      (GetServerMotd200ResponseDataBuilder()..update(updates))._build();

  _$GetServerMotd200ResponseData._({this.motd}) : super._();
  @override
  GetServerMotd200ResponseData rebuild(
          void Function(GetServerMotd200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetServerMotd200ResponseDataBuilder toBuilder() =>
      GetServerMotd200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetServerMotd200ResponseData && motd == other.motd;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, motd.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetServerMotd200ResponseData')
          ..add('motd', motd))
        .toString();
  }
}

class GetServerMotd200ResponseDataBuilder
    implements
        Builder<GetServerMotd200ResponseData,
            GetServerMotd200ResponseDataBuilder> {
  _$GetServerMotd200ResponseData? _$v;

  String? _motd;
  String? get motd => _$this._motd;
  set motd(String? motd) => _$this._motd = motd;

  GetServerMotd200ResponseDataBuilder() {
    GetServerMotd200ResponseData._defaults(this);
  }

  GetServerMotd200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _motd = $v.motd;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetServerMotd200ResponseData other) {
    _$v = other as _$GetServerMotd200ResponseData;
  }

  @override
  void update(void Function(GetServerMotd200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetServerMotd200ResponseData build() => _build();

  _$GetServerMotd200ResponseData _build() {
    final _$result = _$v ??
        _$GetServerMotd200ResponseData._(
          motd: motd,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
