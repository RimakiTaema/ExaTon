//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/get_server_log200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_server_log200_response.g.dart';

/// GetServerLog200Response
///
/// Properties:
/// * [success] 
/// * [error] 
/// * [data] 
@BuiltValue()
abstract class GetServerLog200Response implements Built<GetServerLog200Response, GetServerLog200ResponseBuilder> {
  @BuiltValueField(wireName: r'success')
  bool? get success;

  @BuiltValueField(wireName: r'error')
  String? get error;

  @BuiltValueField(wireName: r'data')
  GetServerLog200ResponseData? get data;

  GetServerLog200Response._();

  factory GetServerLog200Response([void updates(GetServerLog200ResponseBuilder b)]) = _$GetServerLog200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetServerLog200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetServerLog200Response> get serializer => _$GetServerLog200ResponseSerializer();
}

class _$GetServerLog200ResponseSerializer implements PrimitiveSerializer<GetServerLog200Response> {
  @override
  final Iterable<Type> types = const [GetServerLog200Response, _$GetServerLog200Response];

  @override
  final String wireName = r'GetServerLog200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetServerLog200Response object, {
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
        specifiedType: const FullType.nullable(GetServerLog200ResponseData),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetServerLog200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetServerLog200ResponseBuilder result,
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
            specifiedType: const FullType.nullable(GetServerLog200ResponseData),
          ) as GetServerLog200ResponseData?;
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
  GetServerLog200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetServerLog200ResponseBuilder();
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

