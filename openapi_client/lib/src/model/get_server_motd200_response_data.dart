//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_server_motd200_response_data.g.dart';

/// GetServerMotd200ResponseData
///
/// Properties:
/// * [motd] - The MOTD of the server
@BuiltValue()
abstract class GetServerMotd200ResponseData implements Built<GetServerMotd200ResponseData, GetServerMotd200ResponseDataBuilder> {
  /// The MOTD of the server
  @BuiltValueField(wireName: r'motd')
  String? get motd;

  GetServerMotd200ResponseData._();

  factory GetServerMotd200ResponseData([void updates(GetServerMotd200ResponseDataBuilder b)]) = _$GetServerMotd200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetServerMotd200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetServerMotd200ResponseData> get serializer => _$GetServerMotd200ResponseDataSerializer();
}

class _$GetServerMotd200ResponseDataSerializer implements PrimitiveSerializer<GetServerMotd200ResponseData> {
  @override
  final Iterable<Type> types = const [GetServerMotd200ResponseData, _$GetServerMotd200ResponseData];

  @override
  final String wireName = r'GetServerMotd200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetServerMotd200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.motd != null) {
      yield r'motd';
      yield serializers.serialize(
        object.motd,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetServerMotd200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetServerMotd200ResponseDataBuilder result,
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
  GetServerMotd200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetServerMotd200ResponseDataBuilder();
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

