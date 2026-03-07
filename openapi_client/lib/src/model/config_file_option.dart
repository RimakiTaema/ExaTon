//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/config_file_option_value.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'config_file_option.g.dart';

/// ConfigFileOption
///
/// Properties:
/// * [key] 
/// * [label] 
/// * [type] 
/// * [value] 
/// * [options] 
@BuiltValue()
abstract class ConfigFileOption implements Built<ConfigFileOption, ConfigFileOptionBuilder> {
  @BuiltValueField(wireName: r'key')
  String? get key;

  @BuiltValueField(wireName: r'label')
  String? get label;

  @BuiltValueField(wireName: r'type')
  String? get type;

  @BuiltValueField(wireName: r'value')
  ConfigFileOptionValue? get value;

  @BuiltValueField(wireName: r'options')
  BuiltList<String>? get options;

  ConfigFileOption._();

  factory ConfigFileOption([void updates(ConfigFileOptionBuilder b)]) = _$ConfigFileOption;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfigFileOptionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfigFileOption> get serializer => _$ConfigFileOptionSerializer();
}

class _$ConfigFileOptionSerializer implements PrimitiveSerializer<ConfigFileOption> {
  @override
  final Iterable<Type> types = const [ConfigFileOption, _$ConfigFileOption];

  @override
  final String wireName = r'ConfigFileOption';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfigFileOption object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.key != null) {
      yield r'key';
      yield serializers.serialize(
        object.key,
        specifiedType: const FullType(String),
      );
    }
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType(String),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(String),
      );
    }
    if (object.value != null) {
      yield r'value';
      yield serializers.serialize(
        object.value,
        specifiedType: const FullType(ConfigFileOptionValue),
      );
    }
    if (object.options != null) {
      yield r'options';
      yield serializers.serialize(
        object.options,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfigFileOption object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfigFileOptionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ConfigFileOptionValue),
          ) as ConfigFileOptionValue;
          result.value.replace(valueDes);
          break;
        case r'options':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.options.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfigFileOption deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfigFileOptionBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

