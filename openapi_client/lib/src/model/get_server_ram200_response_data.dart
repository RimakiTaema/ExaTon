//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_server_ram200_response_data.g.dart';

/// GetServerRam200ResponseData
///
/// Properties:
/// * [ram] - How many GB ram this server has
@BuiltValue()
abstract class GetServerRam200ResponseData implements Built<GetServerRam200ResponseData, GetServerRam200ResponseDataBuilder> {
  /// How many GB ram this server has
  @BuiltValueField(wireName: r'ram')
  int? get ram;

  GetServerRam200ResponseData._();

  factory GetServerRam200ResponseData([void updates(GetServerRam200ResponseDataBuilder b)]) = _$GetServerRam200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetServerRam200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetServerRam200ResponseData> get serializer => _$GetServerRam200ResponseDataSerializer();
}

class _$GetServerRam200ResponseDataSerializer implements PrimitiveSerializer<GetServerRam200ResponseData> {
  @override
  final Iterable<Type> types = const [GetServerRam200ResponseData, _$GetServerRam200ResponseData];

  @override
  final String wireName = r'GetServerRam200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetServerRam200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ram != null) {
      yield r'ram';
      yield serializers.serialize(
        object.ram,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetServerRam200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetServerRam200ResponseDataBuilder result,
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
  GetServerRam200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetServerRam200ResponseDataBuilder();
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

