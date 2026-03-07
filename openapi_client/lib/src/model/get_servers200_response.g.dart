// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_servers200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetServers200Response extends GetServers200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final BuiltList<Server>? data;

  factory _$GetServers200Response(
          [void Function(GetServers200ResponseBuilder)? updates]) =>
      (GetServers200ResponseBuilder()..update(updates))._build();

  _$GetServers200Response._({this.success, this.error, this.data}) : super._();
  @override
  GetServers200Response rebuild(
          void Function(GetServers200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetServers200ResponseBuilder toBuilder() =>
      GetServers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetServers200Response &&
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
    return (newBuiltValueToStringHelper(r'GetServers200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetServers200ResponseBuilder
    implements Builder<GetServers200Response, GetServers200ResponseBuilder> {
  _$GetServers200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  ListBuilder<Server>? _data;
  ListBuilder<Server> get data => _$this._data ??= ListBuilder<Server>();
  set data(ListBuilder<Server>? data) => _$this._data = data;

  GetServers200ResponseBuilder() {
    GetServers200Response._defaults(this);
  }

  GetServers200ResponseBuilder get _$this {
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
  void replace(GetServers200Response other) {
    _$v = other as _$GetServers200Response;
  }

  @override
  void update(void Function(GetServers200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetServers200Response build() => _build();

  _$GetServers200Response _build() {
    _$GetServers200Response _$result;
    try {
      _$result = _$v ??
          _$GetServers200Response._(
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
            r'GetServers200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
