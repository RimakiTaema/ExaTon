//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_server_log200_response_data.g.dart';

/// GetServerLog200ResponseData
///
/// Properties:
/// * [content] 
@BuiltValue()
abstract class GetServerLog200ResponseData implements Built<GetServerLog200ResponseData, GetServerLog200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'content')
  String? get content;

  GetServerLog200ResponseData._();

  factory GetServerLog200ResponseData([void updates(GetServerLog200ResponseDataBuilder b)]) = _$GetServerLog200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetServerLog200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetServerLog200ResponseData> get serializer => _$GetServerLog200ResponseDataSerializer();
}

class _$GetServerLog200ResponseDataSerializer implements PrimitiveSerializer<GetServerLog200ResponseData> {
  @override
  final Iterable<Type> types = const [GetServerLog200ResponseData, _$GetServerLog200ResponseData];

  @override
  final String wireName = r'GetServerLog200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetServerLog200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetServerLog200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetServerLog200ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.content = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetServerLog200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetServerLog200ResponseDataBuilder();
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

