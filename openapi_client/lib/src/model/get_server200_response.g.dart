// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_server200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetServer200Response extends GetServer200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final Server? data;

  factory _$GetServer200Response(
          [void Function(GetServer200ResponseBuilder)? updates]) =>
      (GetServer200ResponseBuilder()..update(updates))._build();

  _$GetServer200Response._({this.success, this.error, this.data}) : super._();
  @override
  GetServer200Response rebuild(
          void Function(GetServer200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetServer200ResponseBuilder toBuilder() =>
      GetServer200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetServer200Response &&
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
    return (newBuiltValueToStringHelper(r'GetServer200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetServer200ResponseBuilder
    implements Builder<GetServer200Response, GetServer200ResponseBuilder> {
  _$GetServer200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  ServerBuilder? _data;
  ServerBuilder get data => _$this._data ??= ServerBuilder();
  set data(ServerBuilder? data) => _$this._data = data;

  GetServer200ResponseBuilder() {
    GetServer200Response._defaults(this);
  }

  GetServer200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _success = $v.success;
      _error = $v.error;
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetServer200Response other) {
    _$v = other as _$GetServer200Response;
  }

  @override
  void update(void Function(GetServer200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetServer200Response build() => _build();

  _$GetServer200Response _build() {
    _$GetServer200Response _$result;
    try {
      _$result = _$v ??
          _$GetServer200Response._(
            success: success,
            error: error,
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetServer200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
