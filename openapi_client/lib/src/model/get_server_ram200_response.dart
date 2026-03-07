//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/get_server_ram200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_server_ram200_response.g.dart';

/// GetServerRam200Response
///
/// Properties:
/// * [success] 
/// * [error] 
/// * [data] 
@BuiltValue()
abstract class GetServerRam200Response implements Built<GetServerRam200Response, GetServerRam200ResponseBuilder> {
  @BuiltValueField(wireName: r'success')
  bool? get success;

  @BuiltValueField(wireName: r'error')
  String? get error;

  @BuiltValueField(wireName: r'data')
  GetServerRam200ResponseData? get data;

  GetServerRam200Response._();

  factory GetServerRam200Response([void updates(GetServerRam200ResponseBuilder b)]) = _$GetServerRam200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetServerRam200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetServerRam200Response> get serializer => _$GetServerRam200ResponseSerializer();
}

class _$GetServerRam200ResponseSerializer implements PrimitiveSerializer<GetServerRam200Response> {
  @override
  final Iterable<Type> types = const [GetServerRam200Response, _$GetServerRam200Response];

  @override
  final String wireName = r'GetServerRam200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetServerRam200Response object, {
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
        specifiedType: const FullType.nullable(GetServerRam200ResponseData),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetServerRam200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetServerRam200ResponseBuilder result,
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
            specifiedType: const FullType.nullable(GetServerRam200ResponseData),
          ) as GetServerRam200ResponseData?;
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
  GetServerRam200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetServerRam200ResponseBuilder();
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

