// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_file_info200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFileInfo200Response extends GetFileInfo200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final FileInfo? data;

  factory _$GetFileInfo200Response(
          [void Function(GetFileInfo200ResponseBuilder)? updates]) =>
      (GetFileInfo200ResponseBuilder()..update(updates))._build();

  _$GetFileInfo200Response._({this.success, this.error, this.data}) : super._();
  @override
  GetFileInfo200Response rebuild(
          void Function(GetFileInfo200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFileInfo200ResponseBuilder toBuilder() =>
      GetFileInfo200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFileInfo200Response &&
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
    return (newBuiltValueToStringHelper(r'GetFileInfo200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetFileInfo200ResponseBuilder
    implements Builder<GetFileInfo200Response, GetFileInfo200ResponseBuilder> {
  _$GetFileInfo200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  FileInfoBuilder? _data;
  FileInfoBuilder get data => _$this._data ??= FileInfoBuilder();
  set data(FileInfoBuilder? data) => _$this._data = data;

  GetFileInfo200ResponseBuilder() {
    GetFileInfo200Response._defaults(this);
  }

  GetFileInfo200ResponseBuilder get _$this {
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
  void replace(GetFileInfo200Response other) {
    _$v = other as _$GetFileInfo200Response;
  }

  @override
  void update(void Function(GetFileInfo200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFileInfo200Response build() => _build();

  _$GetFileInfo200Response _build() {
    _$GetFileInfo200Response _$result;
    try {
      _$result = _$v ??
          _$GetFileInfo200Response._(
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
            r'GetFileInfo200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
