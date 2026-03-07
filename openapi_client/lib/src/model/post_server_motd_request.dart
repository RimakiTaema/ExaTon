//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_server_motd_request.g.dart';

/// PostServerMotdRequest
///
/// Properties:
/// * [motd] - The new MOTD for the server
@BuiltValue()
abstract class PostServerMotdRequest implements Built<PostServerMotdRequest, PostServerMotdRequestBuilder> {
  /// The new MOTD for the server
  @BuiltValueField(wireName: r'motd')
  String get motd;

  PostServerMotdRequest._();

  factory PostServerMotdRequest([void updates(PostServerMotdRequestBuilder b)]) = _$PostServerMotdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostServerMotdRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostServerMotdRequest> get serializer => _$PostServerMotdRequestSerializer();
}

class _$PostServerMotdRequestSerializer implements PrimitiveSerializer<PostServerMotdRequest> {
  @override
  final Iterable<Type> types = const [PostServerMotdRequest, _$PostServerMotdRequest];

  @override
  final String wireName = r'PostServerMotdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostServerMotdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'motd';
    yield serializers.serialize(
      object.motd,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostServerMotdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostServerMotdRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'motd':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.motd = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostServerMotdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostServerMotdRequestBuilder();
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

