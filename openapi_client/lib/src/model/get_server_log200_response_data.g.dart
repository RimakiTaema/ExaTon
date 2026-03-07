// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_server_log200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetServerLog200ResponseData extends GetServerLog200ResponseData {
  @override
  final String? content;

  factory _$GetServerLog200ResponseData(
          [void Function(GetServerLog200ResponseDataBuilder)? updates]) =>
      (GetServerLog200ResponseDataBuilder()..update(updates))._build();

  _$GetServerLog200ResponseData._({this.content}) : super._();
  @override
  GetServerLog200ResponseData rebuild(
          void Function(GetServerLog200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetServerLog200ResponseDataBuilder toBuilder() =>
      GetServerLog200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetServerLog200ResponseData && content == other.content;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetServerLog200ResponseData')
          ..add('content', content))
        .toString();
  }
}

class GetServerLog200ResponseDataBuilder
    implements
        Builder<GetServerLog200ResponseData,
            GetServerLog200ResponseDataBuilder> {
  _$GetServerLog200ResponseData? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  GetServerLog200ResponseDataBuilder() {
    GetServerLog200ResponseData._defaults(this);
  }

  GetServerLog200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetServerLog200ResponseData other) {
    _$v = other as _$GetServerLog200ResponseData;
  }

  @override
  void update(void Function(GetServerLog200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetServerLog200ResponseData build() => _build();

  _$GetServerLog200ResponseData _build() {
    final _$result = _$v ??
        _$GetServerLog200ResponseData._(
          content: content,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
