//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'share_server_log200_response_data.g.dart';

/// ShareServerLog200ResponseData
///
/// Properties:
/// * [id] - ID on mclo.gs
/// * [url] - URL to shared logs on mclo.gs
/// * [raw] - URL to api of mclo.gs
@BuiltValue()
abstract class ShareServerLog200ResponseData implements Built<ShareServerLog200ResponseData, ShareServerLog200ResponseDataBuilder> {
  /// ID on mclo.gs
  @BuiltValueField(wireName: r'id')
  String? get id;

  /// URL to shared logs on mclo.gs
  @BuiltValueField(wireName: r'url')
  String? get url;

  /// URL to api of mclo.gs
  @BuiltValueField(wireName: r'raw')
  String? get raw;

  ShareServerLog200ResponseData._();

  factory ShareServerLog200ResponseData([void updates(ShareServerLog200ResponseDataBuilder b)]) = _$ShareServerLog200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ShareServerLog200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ShareServerLog200ResponseData> get serializer => _$ShareServerLog200ResponseDataSerializer();
}

class _$ShareServerLog200ResponseDataSerializer implements PrimitiveSerializer<ShareServerLog200ResponseData> {
  @override
  final Iterable<Type> types = const [ShareServerLog200ResponseData, _$ShareServerLog200ResponseData];

  @override
  final String wireName = r'ShareServerLog200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ShareServerLog200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.url != null) {
      yield r'url';
      yield serializers.serialize(
        object.url,
        specifiedType: const FullType(String),
      );
    }
    if (object.raw != null) {
      yield r'raw';
      yield serializers.serialize(
        object.raw,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ShareServerLog200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ShareServerLog200ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'raw':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.raw = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ShareServerLog200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ShareServerLog200ResponseDataBuilder();
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

