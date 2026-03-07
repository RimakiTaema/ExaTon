//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'config_file_option_value.g.dart';

/// ConfigFileOptionValue
@BuiltValue()
abstract class ConfigFileOptionValue implements Built<ConfigFileOptionValue, ConfigFileOptionValueBuilder> {
  /// One Of [String], [bool], [int]
  OneOf get oneOf;

  ConfigFileOptionValue._();

  factory ConfigFileOptionValue([void updates(ConfigFileOptionValueBuilder b)]) = _$ConfigFileOptionValue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfigFileOptionValueBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfigFileOptionValue> get serializer => _$ConfigFileOptionValueSerializer();
}

class _$ConfigFileOptionValueSerializer implements PrimitiveSerializer<ConfigFileOptionValue> {
  @override
  final Iterable<Type> types = const [ConfigFileOptionValue, _$ConfigFileOptionValue];

  @override
  final String wireName = r'ConfigFileOptionValue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfigFileOptionValue object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfigFileOptionValue object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  ConfigFileOptionValue deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfigFileOptionValueBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [FullType(String), FullType(int), FullType(bool), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
    return result.build();
  }
}

