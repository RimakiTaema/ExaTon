//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_server_ram_request.g.dart';

/// PostServerRamRequest
///
/// Properties:
/// * [ram] - How many GB ram this server should have
@BuiltValue()
abstract class PostServerRamRequest implements Built<PostServerRamRequest, PostServerRamRequestBuilder> {
  /// How many GB ram this server should have
  @BuiltValueField(wireName: r'ram')
  int get ram;

  PostServerRamRequest._();

  factory PostServerRamRequest([void updates(PostServerRamRequestBuilder b)]) = _$PostServerRamRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostServerRamRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostServerRamRequest> get serializer => _$PostServerRamRequestSerializer();
}

class _$PostServerRamRequestSerializer implements PrimitiveSerializer<PostServerRamRequest> {
  @override
  final Iterable<Type> types = const [PostServerRamRequest, _$PostServerRamRequest];

  @override
  final String wireName = r'PostServerRamRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostServerRamRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ram';
    yield serializers.serialize(
      object.ram,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostServerRamRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostServerRamRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ram':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ram = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostServerRamRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostServerRamRequestBuilder();
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

