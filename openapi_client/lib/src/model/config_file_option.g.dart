// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_file_option.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfigFileOption extends ConfigFileOption {
  @override
  final String? key;
  @override
  final String? label;
  @override
  final String? type;
  @override
  final ConfigFileOptionValue? value;
  @override
  final BuiltList<String>? options;

  factory _$ConfigFileOption(
          [void Function(ConfigFileOptionBuilder)? updates]) =>
      (ConfigFileOptionBuilder()..update(updates))._build();

  _$ConfigFileOption._(
      {this.key, this.label, this.type, this.value, this.options})
      : super._();
  @override
  ConfigFileOption rebuild(void Function(ConfigFileOptionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfigFileOptionBuilder toBuilder() =>
      ConfigFileOptionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfigFileOption &&
        key == other.key &&
        label == other.label &&
        type == other.type &&
        value == other.value &&
        options == other.options;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, options.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfigFileOption')
          ..add('key', key)
          ..add('label', label)
          ..add('type', type)
          ..add('value', value)
          ..add('options', options))
        .toString();
  }
}

class ConfigFileOptionBuilder
    implements Builder<ConfigFileOption, ConfigFileOptionBuilder> {
  _$ConfigFileOption? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  ConfigFileOptionValueBuilder? _value;
  ConfigFileOptionValueBuilder get value =>
      _$this._value ??= ConfigFileOptionValueBuilder();
  set value(ConfigFileOptionValueBuilder? value) => _$this._value = value;

  ListBuilder<String>? _options;
  ListBuilder<String> get options => _$this._options ??= ListBuilder<String>();
  set options(ListBuilder<String>? options) => _$this._options = options;

  ConfigFileOptionBuilder() {
    ConfigFileOption._defaults(this);
  }

  ConfigFileOptionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _label = $v.label;
      _type = $v.type;
      _value = $v.value?.toBuilder();
      _options = $v.options?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfigFileOption other) {
    _$v = other as _$ConfigFileOption;
  }

  @override
  void update(void Function(ConfigFileOptionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfigFileOption build() => _build();

  _$ConfigFileOption _build() {
    _$ConfigFileOption _$result;
    try {
      _$result = _$v ??
          _$ConfigFileOption._(
            key: key,
            label: label,
            type: type,
            value: _value?.build(),
            options: _options?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'value';
        _value?.build();
        _$failedField = 'options';
        _options?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ConfigFileOption', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
