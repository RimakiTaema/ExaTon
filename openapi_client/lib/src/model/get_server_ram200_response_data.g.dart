// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_server_ram200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetServerRam200ResponseData extends GetServerRam200ResponseData {
  @override
  final int? ram;

  factory _$GetServerRam200ResponseData(
          [void Function(GetServerRam200ResponseDataBuilder)? updates]) =>
      (GetServerRam200ResponseDataBuilder()..update(updates))._build();

  _$GetServerRam200ResponseData._({this.ram}) : super._();
  @override
  GetServerRam200ResponseData rebuild(
          void Function(GetServerRam200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetServerRam200ResponseDataBuilder toBuilder() =>
      GetServerRam200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetServerRam200ResponseData && ram == other.ram;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ram.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetServerRam200ResponseData')
          ..add('ram', ram))
        .toString();
  }
}

class GetServerRam200ResponseDataBuilder
    implements
        Builder<GetServerRam200ResponseData,
            GetServerRam200ResponseDataBuilder> {
  _$GetServerRam200ResponseData? _$v;

  int? _ram;
  int? get ram => _$this._ram;
  set ram(int? ram) => _$this._ram = ram;

  GetServerRam200ResponseDataBuilder() {
    GetServerRam200ResponseData._defaults(this);
  }

  GetServerRam200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ram = $v.ram;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetServerRam200ResponseData other) {
    _$v = other as _$GetServerRam200ResponseData;
  }

  @override
  void update(void Function(GetServerRam200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetServerRam200ResponseData build() => _build();

  _$GetServerRam200ResponseData _build() {
    final _$result = _$v ??
        _$GetServerRam200ResponseData._(
          ram: ram,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
