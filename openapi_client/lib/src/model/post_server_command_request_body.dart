//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_server_command_request_body.g.dart';

/// PostServerCommandRequestBody
///
/// Properties:
/// * [command] - The command to send to the server
@BuiltValue()
abstract class PostServerCommandRequestBody implements Built<PostServerCommandRequestBody, PostServerCommandRequestBodyBuilder> {
  /// The command to send to the server
  @BuiltValueField(wireName: r'command')
  String? get command;

  PostServerCommandRequestBody._();

  factory PostServerCommandRequestBody([void updates(PostServerCommandRequestBodyBuilder b)]) = _$PostServerCommandRequestBody;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostServerCommandRequestBodyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostServerCommandRequestBody> get serializer => _$PostServerCommandRequestBodySerializer();
}

class _$PostServerCommandRequestBodySerializer implements PrimitiveSerializer<PostServerCommandRequestBody> {
  @override
  final Iterable<Type> types = const [PostServerCommandRequestBody, _$PostServerCommandRequestBody];

  @override
  final String wireName = r'PostServerCommandRequestBody';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostServerCommandRequestBody object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.command != null) {
      yield r'command';
      yield serializers.serialize(
        object.command,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostServerCommandRequestBody object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostServerCommandRequestBodyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'command':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.command = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostServerCommandRequestBody deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostServerCommandRequestBodyBuilder();
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

