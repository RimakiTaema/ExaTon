// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_server_log200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShareServerLog200Response extends ShareServerLog200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final ShareServerLog200ResponseData? data;

  factory _$ShareServerLog200Response(
          [void Function(ShareServerLog200ResponseBuilder)? updates]) =>
      (ShareServerLog200ResponseBuilder()..update(updates))._build();

  _$ShareServerLog200Response._({this.success, this.error, this.data})
      : super._();
  @override
  ShareServerLog200Response rebuild(
          void Function(ShareServerLog200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShareServerLog200ResponseBuilder toBuilder() =>
      ShareServerLog200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShareServerLog200Response &&
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
    return (newBuiltValueToStringHelper(r'ShareServerLog200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class ShareServerLog200ResponseBuilder
    implements
        Builder<ShareServerLog200Response, ShareServerLog200ResponseBuilder> {
  _$ShareServerLog200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  ShareServerLog200ResponseDataBuilder? _data;
  ShareServerLog200ResponseDataBuilder get data =>
      _$this._data ??= ShareServerLog200ResponseDataBuilder();
  set data(ShareServerLog200ResponseDataBuilder? data) => _$this._data = data;

  ShareServerLog200ResponseBuilder() {
    ShareServerLog200Response._defaults(this);
  }

  ShareServerLog200ResponseBuilder get _$this {
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
  void replace(ShareServerLog200Response other) {
    _$v = other as _$ShareServerLog200Response;
  }

  @override
  void update(void Function(ShareServerLog200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShareServerLog200Response build() => _build();

  _$ShareServerLog200Response _build() {
    _$ShareServerLog200Response _$result;
    try {
      _$result = _$v ??
          _$ShareServerLog200Response._(
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
            r'ShareServerLog200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
