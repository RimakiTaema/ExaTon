//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/server_software.dart';
import 'package:openapi/src/model/server_status.dart';
import 'package:openapi/src/model/server_players.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'server.g.dart';

/// Server
///
/// Properties:
/// * [id] - Unique server ID
/// * [name] - Server name
/// * [address] - Full server address
/// * [motd] - The MOTD of the server
/// * [status] 
/// * [host] - Host machine the server is running on. Only available if the server is online.
/// * [port] - Port the server is listening on. Only available if the server is online.
/// * [players] 
/// * [software] 
/// * [shared] - Whether the server is accessed via the Share Access feature
@BuiltValue()
abstract class Server implements Built<Server, ServerBuilder> {
  /// Unique server ID
  @BuiltValueField(wireName: r'id')
  String? get id;

  /// Server name
  @BuiltValueField(wireName: r'name')
  String? get name;

  /// Full server address
  @BuiltValueField(wireName: r'address')
  String? get address;

  /// The MOTD of the server
  @BuiltValueField(wireName: r'motd')
  String? get motd;

  @BuiltValueField(wireName: r'status')
  ServerStatus? get status;
  // enum statusEnum {  0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10,  };

  /// Host machine the server is running on. Only available if the server is online.
  @BuiltValueField(wireName: r'host')
  String? get host;

  /// Port the server is listening on. Only available if the server is online.
  @BuiltValueField(wireName: r'port')
  int? get port;

  @BuiltValueField(wireName: r'players')
  ServerPlayers? get players;

  @BuiltValueField(wireName: r'software')
  ServerSoftware? get software;

  /// Whether the server is accessed via the Share Access feature
  @BuiltValueField(wireName: r'shared')
  bool? get shared;

  Server._();

  factory Server([void updates(ServerBuilder b)]) = _$Server;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ServerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Server> get serializer => _$ServerSerializer();
}

class _$ServerSerializer implements PrimitiveSerializer<Server> {
  @override
  final Iterable<Type> types = const [Server, _$Server];

  @override
  final String wireName = r'Server';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Server object, {
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
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType(String),
      );
    }
    if (object.motd != null) {
      yield r'motd';
      yield serializers.serialize(
        object.motd,
        specifiedType: const FullType(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(ServerStatus),
      );
    }
    if (object.host != null) {
      yield r'host';
      yield serializers.serialize(
        object.host,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.port != null) {
      yield r'port';
      yield serializers.serialize(
        object.port,
        specifiedType: const FullType(int),
      );
    }
    if (object.players != null) {
      yield r'players';
      yield serializers.serialize(
        object.players,
        specifiedType: const FullType(ServerPlayers),
      );
    }
    if (object.software != null) {
      yield r'software';
      yield serializers.serialize(
        object.software,
        specifiedType: const FullType.nullable(ServerSoftware),
      );
    }
    if (object.shared != null) {
      yield r'shared';
      yield serializers.serialize(
        object.shared,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Server object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ServerBuilder result,
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
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.address = valueDes;
          break;
        case r'motd':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.motd = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ServerStatus),
          ) as ServerStatus;
          result.status = valueDes;
          break;
        case r'host':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.host = valueDes;
          break;
        case r'port':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.port = valueDes;
          break;
        case r'players':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ServerPlayers),
          ) as ServerPlayers;
          result.players.replace(valueDes);
          break;
        case r'software':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ServerSoftware),
          ) as ServerSoftware?;
          if (valueDes == null) continue;
          result.software.replace(valueDes);
          break;
        case r'shared':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.shared = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Server deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ServerBuilder();
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

