// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_server_motd200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetServerMotd200Response extends GetServerMotd200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final GetServerMotd200ResponseData? data;

  factory _$GetServerMotd200Response(
          [void Function(GetServerMotd200ResponseBuilder)? updates]) =>
      (GetServerMotd200ResponseBuilder()..update(updates))._build();

  _$GetServerMotd200Response._({this.success, this.error, this.data})
      : super._();
  @override
  GetServerMotd200Response rebuild(
          void Function(GetServerMotd200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetServerMotd200ResponseBuilder toBuilder() =>
      GetServerMotd200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetServerMotd200Response &&
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
    return (newBuiltValueToStringHelper(r'GetServerMotd200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetServerMotd200ResponseBuilder
    implements
        Builder<GetServerMotd200Response, GetServerMotd200ResponseBuilder> {
  _$GetServerMotd200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  GetServerMotd200ResponseDataBuilder? _data;
  GetServerMotd200ResponseDataBuilder get data =>
      _$this._data ??= GetServerMotd200ResponseDataBuilder();
  set data(GetServerMotd200ResponseDataBuilder? data) => _$this._data = data;

  GetServerMotd200ResponseBuilder() {
    GetServerMotd200Response._defaults(this);
  }

  GetServerMotd200ResponseBuilder get _$this {
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
  void replace(GetServerMotd200Response other) {
    _$v = other as _$GetServerMotd200Response;
  }

  @override
  void update(void Function(GetServerMotd200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetServerMotd200Response build() => _build();

  _$GetServerMotd200Response _build() {
    _$GetServerMotd200Response _$result;
    try {
      _$result = _$v ??
          _$GetServerMotd200Response._(
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
            r'GetServerMotd200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
