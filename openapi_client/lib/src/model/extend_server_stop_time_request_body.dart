//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'extend_server_stop_time_request_body.g.dart';

/// ExtendServerStopTimeRequestBody
///
/// Properties:
/// * [time] - Number of seconds to extend the stop timer by
@BuiltValue()
abstract class ExtendServerStopTimeRequestBody implements Built<ExtendServerStopTimeRequestBody, ExtendServerStopTimeRequestBodyBuilder> {
  /// Number of seconds to extend the stop timer by
  @BuiltValueField(wireName: r'time')
  int? get time;

  ExtendServerStopTimeRequestBody._();

  factory ExtendServerStopTimeRequestBody([void updates(ExtendServerStopTimeRequestBodyBuilder b)]) = _$ExtendServerStopTimeRequestBody;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExtendServerStopTimeRequestBodyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExtendServerStopTimeRequestBody> get serializer => _$ExtendServerStopTimeRequestBodySerializer();
}

class _$ExtendServerStopTimeRequestBodySerializer implements PrimitiveSerializer<ExtendServerStopTimeRequestBody> {
  @override
  final Iterable<Type> types = const [ExtendServerStopTimeRequestBody, _$ExtendServerStopTimeRequestBody];

  @override
  final String wireName = r'ExtendServerStopTimeRequestBody';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExtendServerStopTimeRequestBody object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.time != null) {
      yield r'time';
      yield serializers.serialize(
        object.time,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ExtendServerStopTimeRequestBody object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExtendServerStopTimeRequestBodyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.time = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExtendServerStopTimeRequestBody deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExtendServerStopTimeRequestBodyBuilder();
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

