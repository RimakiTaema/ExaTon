// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_start_server200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetStartServer200Response extends GetStartServer200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final JsonObject? data;

  factory _$GetStartServer200Response(
          [void Function(GetStartServer200ResponseBuilder)? updates]) =>
      (GetStartServer200ResponseBuilder()..update(updates))._build();

  _$GetStartServer200Response._({this.success, this.error, this.data})
      : super._();
  @override
  GetStartServer200Response rebuild(
          void Function(GetStartServer200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetStartServer200ResponseBuilder toBuilder() =>
      GetStartServer200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetStartServer200Response &&
        success == other.success &&
        error == other.error &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetStartServer200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetStartServer200ResponseBuilder
    implements
        Builder<GetStartServer200Response, GetStartServer200ResponseBuilder> {
  _$GetStartServer200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  JsonObject? _data;
  JsonObject? get data => _$this._data;
  set data(JsonObject? data) => _$this._data = data;

  GetStartServer200ResponseBuilder() {
    GetStartServer200Response._defaults(this);
  }

  GetStartServer200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _success = $v.success;
      _error = $v.error;
      _data = $v.data;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetStartServer200Response other) {
    _$v = other as _$GetStartServer200Response;
  }

  @override
  void update(void Function(GetStartServer200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetStartServer200Response build() => _build();

  _$GetStartServer200Response _build() {
    final _$result = _$v ??
        _$GetStartServer200Response._(
          success: success,
          error: error,
          data: data,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
