// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_server_log200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetServerLog200Response extends GetServerLog200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final GetServerLog200ResponseData? data;

  factory _$GetServerLog200Response(
          [void Function(GetServerLog200ResponseBuilder)? updates]) =>
      (GetServerLog200ResponseBuilder()..update(updates))._build();

  _$GetServerLog200Response._({this.success, this.error, this.data})
      : super._();
  @override
  GetServerLog200Response rebuild(
          void Function(GetServerLog200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetServerLog200ResponseBuilder toBuilder() =>
      GetServerLog200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetServerLog200Response &&
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
    return (newBuiltValueToStringHelper(r'GetServerLog200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetServerLog200ResponseBuilder
    implements
        Builder<GetServerLog200Response, GetServerLog200ResponseBuilder> {
  _$GetServerLog200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  GetServerLog200ResponseDataBuilder? _data;
  GetServerLog200ResponseDataBuilder get data =>
      _$this._data ??= GetServerLog200ResponseDataBuilder();
  set data(GetServerLog200ResponseDataBuilder? data) => _$this._data = data;

  GetServerLog200ResponseBuilder() {
    GetServerLog200Response._defaults(this);
  }

  GetServerLog200ResponseBuilder get _$this {
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
  void replace(GetServerLog200Response other) {
    _$v = other as _$GetServerLog200Response;
  }

  @override
  void update(void Function(GetServerLog200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetServerLog200Response build() => _build();

  _$GetServerLog200Response _build() {
    _$GetServerLog200Response _$result;
    try {
      _$result = _$v ??
          _$GetServerLog200Response._(
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
            r'GetServerLog200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
