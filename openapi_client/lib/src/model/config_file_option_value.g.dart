// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_file_option_value.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfigFileOptionValue extends ConfigFileOptionValue {
  @override
  final OneOf oneOf;

  factory _$ConfigFileOptionValue(
          [void Function(ConfigFileOptionValueBuilder)? updates]) =>
      (ConfigFileOptionValueBuilder()..update(updates))._build();

  _$ConfigFileOptionValue._({required this.oneOf}) : super._();
  @override
  ConfigFileOptionValue rebuild(
          void Function(ConfigFileOptionValueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfigFileOptionValueBuilder toBuilder() =>
      ConfigFileOptionValueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfigFileOptionValue && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfigFileOptionValue')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class ConfigFileOptionValueBuilder
    implements Builder<ConfigFileOptionValue, ConfigFileOptionValueBuilder> {
  _$ConfigFileOptionValue? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ConfigFileOptionValueBuilder() {
    ConfigFileOptionValue._defaults(this);
  }

  ConfigFileOptionValueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfigFileOptionValue other) {
    _$v = other as _$ConfigFileOptionValue;
  }

  @override
  void update(void Function(ConfigFileOptionValueBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfigFileOptionValue build() => _build();

  _$ConfigFileOptionValue _build() {
    final _$result = _$v ??
        _$ConfigFileOptionValue._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'ConfigFileOptionValue', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
