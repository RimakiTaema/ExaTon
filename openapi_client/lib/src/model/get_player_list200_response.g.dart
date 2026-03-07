// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_player_list200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetPlayerList200Response extends GetPlayerList200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final BuiltList<String>? data;

  factory _$GetPlayerList200Response(
          [void Function(GetPlayerList200ResponseBuilder)? updates]) =>
      (GetPlayerList200ResponseBuilder()..update(updates))._build();

  _$GetPlayerList200Response._({this.success, this.error, this.data})
      : super._();
  @override
  GetPlayerList200Response rebuild(
          void Function(GetPlayerList200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetPlayerList200ResponseBuilder toBuilder() =>
      GetPlayerList200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetPlayerList200Response &&
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
    return (newBuiltValueToStringHelper(r'GetPlayerList200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetPlayerList200ResponseBuilder
    implements
        Builder<GetPlayerList200Response, GetPlayerList200ResponseBuilder> {
  _$GetPlayerList200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  ListBuilder<String>? _data;
  ListBuilder<String> get data => _$this._data ??= ListBuilder<String>();
  set data(ListBuilder<String>? data) => _$this._data = data;

  GetPlayerList200ResponseBuilder() {
    GetPlayerList200Response._defaults(this);
  }

  GetPlayerList200ResponseBuilder get _$this {
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
  void replace(GetPlayerList200Response other) {
    _$v = other as _$GetPlayerList200Response;
  }

  @override
  void update(void Function(GetPlayerList200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetPlayerList200Response build() => _build();

  _$GetPlayerList200Response _build() {
    _$GetPlayerList200Response _$result;
    try {
      _$result = _$v ??
          _$GetPlayerList200Response._(
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
            r'GetPlayerList200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
