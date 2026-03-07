// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_server_ram200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetServerRam200Response extends GetServerRam200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final GetServerRam200ResponseData? data;

  factory _$GetServerRam200Response(
          [void Function(GetServerRam200ResponseBuilder)? updates]) =>
      (GetServerRam200ResponseBuilder()..update(updates))._build();

  _$GetServerRam200Response._({this.success, this.error, this.data})
      : super._();
  @override
  GetServerRam200Response rebuild(
          void Function(GetServerRam200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetServerRam200ResponseBuilder toBuilder() =>
      GetServerRam200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetServerRam200Response &&
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
    return (newBuiltValueToStringHelper(r'GetServerRam200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetServerRam200ResponseBuilder
    implements
        Builder<GetServerRam200Response, GetServerRam200ResponseBuilder> {
  _$GetServerRam200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  GetServerRam200ResponseDataBuilder? _data;
  GetServerRam200ResponseDataBuilder get data =>
      _$this._data ??= GetServerRam200ResponseDataBuilder();
  set data(GetServerRam200ResponseDataBuilder? data) => _$this._data = data;

  GetServerRam200ResponseBuilder() {
    GetServerRam200Response._defaults(this);
  }

  GetServerRam200ResponseBuilder get _$this {
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
  void replace(GetServerRam200Response other) {
    _$v = other as _$GetServerRam200Response;
  }

  @override
  void update(void Function(GetServerRam200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetServerRam200Response build() => _build();

  _$GetServerRam200Response _build() {
    _$GetServerRam200Response _$result;
    try {
      _$result = _$v ??
          _$GetServerRam200Response._(
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
            r'GetServerRam200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
