// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_credit_pool200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetCreditPool200Response extends GetCreditPool200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final CreditPool? data;

  factory _$GetCreditPool200Response(
          [void Function(GetCreditPool200ResponseBuilder)? updates]) =>
      (GetCreditPool200ResponseBuilder()..update(updates))._build();

  _$GetCreditPool200Response._({this.success, this.error, this.data})
      : super._();
  @override
  GetCreditPool200Response rebuild(
          void Function(GetCreditPool200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetCreditPool200ResponseBuilder toBuilder() =>
      GetCreditPool200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetCreditPool200Response &&
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
    return (newBuiltValueToStringHelper(r'GetCreditPool200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetCreditPool200ResponseBuilder
    implements
        Builder<GetCreditPool200Response, GetCreditPool200ResponseBuilder> {
  _$GetCreditPool200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  CreditPoolBuilder? _data;
  CreditPoolBuilder get data => _$this._data ??= CreditPoolBuilder();
  set data(CreditPoolBuilder? data) => _$this._data = data;

  GetCreditPool200ResponseBuilder() {
    GetCreditPool200Response._defaults(this);
  }

  GetCreditPool200ResponseBuilder get _$this {
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
  void replace(GetCreditPool200Response other) {
    _$v = other as _$GetCreditPool200Response;
  }

  @override
  void update(void Function(GetCreditPool200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetCreditPool200Response build() => _build();

  _$GetCreditPool200Response _build() {
    _$GetCreditPool200Response _$result;
    try {
      _$result = _$v ??
          _$GetCreditPool200Response._(
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
            r'GetCreditPool200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
