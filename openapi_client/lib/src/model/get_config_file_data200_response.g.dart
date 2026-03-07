// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_config_file_data200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetConfigFileData200Response extends GetConfigFileData200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final BuiltList<ConfigFileOption>? data;

  factory _$GetConfigFileData200Response(
          [void Function(GetConfigFileData200ResponseBuilder)? updates]) =>
      (GetConfigFileData200ResponseBuilder()..update(updates))._build();

  _$GetConfigFileData200Response._({this.success, this.error, this.data})
      : super._();
  @override
  GetConfigFileData200Response rebuild(
          void Function(GetConfigFileData200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetConfigFileData200ResponseBuilder toBuilder() =>
      GetConfigFileData200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetConfigFileData200Response &&
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
    return (newBuiltValueToStringHelper(r'GetConfigFileData200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetConfigFileData200ResponseBuilder
    implements
        Builder<GetConfigFileData200Response,
            GetConfigFileData200ResponseBuilder> {
  _$GetConfigFileData200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  ListBuilder<ConfigFileOption>? _data;
  ListBuilder<ConfigFileOption> get data =>
      _$this._data ??= ListBuilder<ConfigFileOption>();
  set data(ListBuilder<ConfigFileOption>? data) => _$this._data = data;

  GetConfigFileData200ResponseBuilder() {
    GetConfigFileData200Response._defaults(this);
  }

  GetConfigFileData200ResponseBuilder get _$this {
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
  void replace(GetConfigFileData200Response other) {
    _$v = other as _$GetConfigFileData200Response;
  }

  @override
  void update(void Function(GetConfigFileData200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetConfigFileData200Response build() => _build();

  _$GetConfigFileData200Response _build() {
    _$GetConfigFileData200Response _$result;
    try {
      _$result = _$v ??
          _$GetConfigFileData200Response._(
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
            r'GetConfigFileData200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
