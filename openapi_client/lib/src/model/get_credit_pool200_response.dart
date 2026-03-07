//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/credit_pool.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_credit_pool200_response.g.dart';

/// GetCreditPool200Response
///
/// Properties:
/// * [success] 
/// * [error] 
/// * [data] 
@BuiltValue()
abstract class GetCreditPool200Response implements Built<GetCreditPool200Response, GetCreditPool200ResponseBuilder> {
  @BuiltValueField(wireName: r'success')
  bool? get success;

  @BuiltValueField(wireName: r'error')
  String? get error;

  @BuiltValueField(wireName: r'data')
  CreditPool? get data;

  GetCreditPool200Response._();

  factory GetCreditPool200Response([void updates(GetCreditPool200ResponseBuilder b)]) = _$GetCreditPool200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetCreditPool200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetCreditPool200Response> get serializer => _$GetCreditPool200ResponseSerializer();
}

class _$GetCreditPool200ResponseSerializer implements PrimitiveSerializer<GetCreditPool200Response> {
  @override
  final Iterable<Type> types = const [GetCreditPool200Response, _$GetCreditPool200Response];

  @override
  final String wireName = r'GetCreditPool200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetCreditPool200Response object, {
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
        specifiedType: const FullType(CreditPool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetCreditPool200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetCreditPool200ResponseBuilder result,
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
            specifiedType: const FullType(CreditPool),
          ) as CreditPool;
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
  GetCreditPool200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetCreditPool200ResponseBuilder();
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

