//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/share_server_log200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'share_server_log200_response.g.dart';

/// ShareServerLog200Response
///
/// Properties:
/// * [success] 
/// * [error] 
/// * [data] 
@BuiltValue()
abstract class ShareServerLog200Response implements Built<ShareServerLog200Response, ShareServerLog200ResponseBuilder> {
  @BuiltValueField(wireName: r'success')
  bool? get success;

  @BuiltValueField(wireName: r'error')
  String? get error;

  @BuiltValueField(wireName: r'data')
  ShareServerLog200ResponseData? get data;

  ShareServerLog200Response._();

  factory ShareServerLog200Response([void updates(ShareServerLog200ResponseBuilder b)]) = _$ShareServerLog200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShareServerLog200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShareServerLog200Response> get serializer => _$ShareServerLog200ResponseSerializer();
}

class _$ShareServerLog200ResponseSerializer implements PrimitiveSerializer<ShareServerLog200Response> {
  @override
  final Iterable<Type> types = const [ShareServerLog200Response, _$ShareServerLog200Response];

  @override
  final String wireName = r'ShareServerLog200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShareServerLog200Response object, {
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
        specifiedType: const FullType.nullable(ShareServerLog200ResponseData),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShareServerLog200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShareServerLog200ResponseBuilder result,
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
            specifiedType: const FullType.nullable(ShareServerLog200ResponseData),
          ) as ShareServerLog200ResponseData?;
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
  ShareServerLog200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShareServerLog200ResponseBuilder();
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

