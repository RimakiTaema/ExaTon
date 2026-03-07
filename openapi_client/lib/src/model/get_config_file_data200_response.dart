//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/config_file_option.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_config_file_data200_response.g.dart';

/// GetConfigFileData200Response
///
/// Properties:
/// * [success] 
/// * [error] 
/// * [data] 
@BuiltValue()
abstract class GetConfigFileData200Response implements Built<GetConfigFileData200Response, GetConfigFileData200ResponseBuilder> {
  @BuiltValueField(wireName: r'success')
  bool? get success;

  @BuiltValueField(wireName: r'error')
  String? get error;

  @BuiltValueField(wireName: r'data')
  BuiltList<ConfigFileOption>? get data;

  GetConfigFileData200Response._();

  factory GetConfigFileData200Response([void updates(GetConfigFileData200ResponseBuilder b)]) = _$GetConfigFileData200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetConfigFileData200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetConfigFileData200Response> get serializer => _$GetConfigFileData200ResponseSerializer();
}

class _$GetConfigFileData200ResponseSerializer implements PrimitiveSerializer<GetConfigFileData200Response> {
  @override
  final Iterable<Type> types = const [GetConfigFileData200Response, _$GetConfigFileData200Response];

  @override
  final String wireName = r'GetConfigFileData200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetConfigFileData200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.success != null) {
      yield r'success';
      yield serializers.serialize(
        object.success,
        specifiedType: const FullType(bool),
      );
    }
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.data != null) {
      yield r'data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType.nullable(BuiltList, [FullType(ConfigFileOption)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetConfigFileData200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetConfigFileData200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'success':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.success = valueDes;
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.error = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(ConfigFileOption)]),
          ) as BuiltList<ConfigFileOption>?;
          if (valueDes == null) continue;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetConfigFileData200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetConfigFileData200ResponseBuilder();
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

