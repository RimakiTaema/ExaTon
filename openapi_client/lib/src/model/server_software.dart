//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'server_software.g.dart';

/// Information about the installed server software
///
/// Properties:
/// * [id] - Unique software ID
/// * [name] - Software name
/// * [version] - Software version
@BuiltValue()
abstract class ServerSoftware implements Built<ServerSoftware, ServerSoftwareBuilder> {
  /// Unique software ID
  @BuiltValueField(wireName: r'id')
  String? get id;

  /// Software name
  @BuiltValueField(wireName: r'name')
  String? get name;

  /// Software version
  @BuiltValueField(wireName: r'version')
  String? get version;

  ServerSoftware._();

  factory ServerSoftware([void updates(ServerSoftwareBuilder b)]) = _$ServerSoftware;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ServerSoftwareBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ServerSoftware> get serializer => _$ServerSoftwareSerializer();
}

class _$ServerSoftwareSerializer implements PrimitiveSerializer<ServerSoftware> {
  @override
  final Iterable<Type> types = const [ServerSoftware, _$ServerSoftware];

  @override
  final String wireName = r'ServerSoftware';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ServerSoftware object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.version != null) {
      yield r'version';
      yield serializers.serialize(
        object.version,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ServerSoftware object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ServerSoftwareBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ServerSoftware deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ServerSoftwareBuilder();
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

