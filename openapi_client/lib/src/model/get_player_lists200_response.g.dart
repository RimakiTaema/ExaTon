// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_player_lists200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetPlayerLists200Response extends GetPlayerLists200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final BuiltList<String>? data;

  factory _$GetPlayerLists200Response(
          [void Function(GetPlayerLists200ResponseBuilder)? updates]) =>
      (GetPlayerLists200ResponseBuilder()..update(updates))._build();

  _$GetPlayerLists200Response._({this.success, this.error, this.data})
      : super._();
  @override
  GetPlayerLists200Response rebuild(
          void Function(GetPlayerLists200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetPlayerLists200ResponseBuilder toBuilder() =>
      GetPlayerLists200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetPlayerLists200Response &&
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
    return (newBuiltValueToStringHelper(r'GetPlayerLists200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetPlayerLists200ResponseBuilder
    implements
        Builder<GetPlayerLists200Response, GetPlayerLists200ResponseBuilder> {
  _$GetPlayerLists200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  ListBuilder<String>? _data;
  ListBuilder<String> get data => _$this._data ??= ListBuilder<String>();
  set data(ListBuilder<String>? data) => _$this._data = data;

  GetPlayerLists200ResponseBuilder() {
    GetPlayerLists200Response._defaults(this);
  }

  GetPlayerLists200ResponseBuilder get _$this {
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
  void replace(GetPlayerLists200Response other) {
    _$v = other as _$GetPlayerLists200Response;
  }

  @override
  void update(void Function(GetPlayerLists200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetPlayerLists200Response build() => _build();

  _$GetPlayerLists200Response _build() {
    _$GetPlayerLists200Response _$result;
    try {
      _$result = _$v ??
          _$GetPlayerLists200Response._(
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
            r'GetPlayerLists200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
