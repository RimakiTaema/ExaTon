// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_credit_pools200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetCreditPools200Response extends GetCreditPools200Response {
  @override
  final bool? success;
  @override
  final String? error;
  @override
  final BuiltList<CreditPool>? data;

  factory _$GetCreditPools200Response(
          [void Function(GetCreditPools200ResponseBuilder)? updates]) =>
      (GetCreditPools200ResponseBuilder()..update(updates))._build();

  _$GetCreditPools200Response._({this.success, this.error, this.data})
      : super._();
  @override
  GetCreditPools200Response rebuild(
          void Function(GetCreditPools200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetCreditPools200ResponseBuilder toBuilder() =>
      GetCreditPools200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetCreditPools200Response &&
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
    return (newBuiltValueToStringHelper(r'GetCreditPools200Response')
          ..add('success', success)
          ..add('error', error)
          ..add('data', data))
        .toString();
  }
}

class GetCreditPools200ResponseBuilder
    implements
        Builder<GetCreditPools200Response, GetCreditPools200ResponseBuilder> {
  _$GetCreditPools200Response? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  ListBuilder<CreditPool>? _data;
  ListBuilder<CreditPool> get data =>
      _$this._data ??= ListBuilder<CreditPool>();
  set data(ListBuilder<CreditPool>? data) => _$this._data = data;

  GetCreditPools200ResponseBuilder() {
    GetCreditPools200Response._defaults(this);
  }

  GetCreditPools200ResponseBuilder get _$this {
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
  void replace(GetCreditPools200Response other) {
    _$v = other as _$GetCreditPools200Response;
  }

  @override
  void update(void Function(GetCreditPools200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetCreditPools200Response build() => _build();

  _$GetCreditPools200Response _build() {
    _$GetCreditPools200Response _$result;
    try {
      _$result = _$v ??
          _$GetCreditPools200Response._(
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
            r'GetCreditPools200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
