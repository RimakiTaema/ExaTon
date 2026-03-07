// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_account200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAccount200Response extends GetAccount200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final GetAccount200ResponseData? data;

  factory _$GetAccount200Response(
          [void Function(GetAccount200ResponseBuilder)? updates]) =>
      (GetAccount200ResponseBuilder()..update(updates))._build();

  _$GetAccount200Response._({this.success, this.error, this.data}) : super._();
  @override
  GetAccount200Response rebuild(
          void Function(GetAccount200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAccount200ResponseBuilder toBuilder() =>
      GetAccount200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAccount200Response &&
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
    return (newBuiltValueToStringHelper(r'GetAccount200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetAccount200ResponseBuilder
    implements Builder<GetAccount200Response, GetAccount200ResponseBuilder> {
  _$GetAccount200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  GetAccount200ResponseDataBuilder? _data;
  GetAccount200ResponseDataBuilder get data =>
      _$this._data ??= GetAccount200ResponseDataBuilder();
  set data(GetAccount200ResponseDataBuilder? data) => _$this._data = data;

  GetAccount200ResponseBuilder() {
    GetAccount200Response._defaults(this);
  }

  GetAccount200ResponseBuilder get _$this {
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
  void replace(GetAccount200Response other) {
    _$v = other as _$GetAccount200Response;
  }

  @override
  void update(void Function(GetAccount200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAccount200Response build() => _build();

  _$GetAccount200Response _build() {
    _$GetAccount200Response _$result;
    try {
      _$result = _$v ??
          _$GetAccount200Response._(
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
            r'GetAccount200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
