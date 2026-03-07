//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'put_player_list_request_body.g.dart';

/// PutPlayerListRequestBody
///
/// Properties:
/// * [entries] 
@BuiltValue()
abstract class PutPlayerListRequestBody implements Built<PutPlayerListRequestBody, PutPlayerListRequestBodyBuilder> {
  @BuiltValueField(wireName: r'entries')
  BuiltList<String>? get entries;

  PutPlayerListRequestBody._();

  factory PutPlayerListRequestBody([void updates(PutPlayerListRequestBodyBuilder b)]) = _$PutPlayerListRequestBody;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PutPlayerListRequestBodyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PutPlayerListRequestBody> get serializer => _$PutPlayerListRequestBodySerializer();
}

class _$PutPlayerListRequestBodySerializer implements PrimitiveSerializer<PutPlayerListRequestBody> {
  @override
  final Iterable<Type> types = const [PutPlayerListRequestBody, _$PutPlayerListRequestBody];

  @override
  final String wireName = r'PutPlayerListRequestBody';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PutPlayerListRequestBody object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.entries != null) {
      yield r'entries';
      yield serializers.serialize(
        object.entries,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PutPlayerListRequestBody object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PutPlayerListRequestBodyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.entries.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PutPlayerListRequestBody deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PutPlayerListRequestBodyBuilder();
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

