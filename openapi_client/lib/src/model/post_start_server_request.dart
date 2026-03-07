//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_start_server_request.g.dart';

/// PostStartServerRequest
///
/// Properties:
/// * [useOwnCredits] 
@BuiltValue()
abstract class PostStartServerRequest implements Built<PostStartServerRequest, PostStartServerRequestBuilder> {
  @BuiltValueField(wireName: r'useOwnCredits')
  bool? get useOwnCredits;

  PostStartServerRequest._();

  factory PostStartServerRequest([void updates(PostStartServerRequestBuilder b)]) = _$PostStartServerRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostStartServerRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostStartServerRequest> get serializer => _$PostStartServerRequestSerializer();
}

class _$PostStartServerRequestSerializer implements PrimitiveSerializer<PostStartServerRequest> {
  @override
  final Iterable<Type> types = const [PostStartServerRequest, _$PostStartServerRequest];

  @override
  final String wireName = r'PostStartServerRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostStartServerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.useOwnCredits != null) {
      yield r'useOwnCredits';
      yield serializers.serialize(
        object.useOwnCredits,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostStartServerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostStartServerRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'useOwnCredits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.useOwnCredits = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostStartServerRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostStartServerRequestBuilder();
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

