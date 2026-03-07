//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'server_players.g.dart';

/// ServerPlayers
///
/// Properties:
/// * [max] - Maximum player count (slots)
/// * [count] - Current player count
/// * [list] - Current player list (not always available)
@BuiltValue()
abstract class ServerPlayers implements Built<ServerPlayers, ServerPlayersBuilder> {
  /// Maximum player count (slots)
  @BuiltValueField(wireName: r'max')
  int? get max;

  /// Current player count
  @BuiltValueField(wireName: r'count')
  int? get count;

  /// Current player list (not always available)
  @BuiltValueField(wireName: r'list')
  BuiltList<String>? get list;

  ServerPlayers._();

  factory ServerPlayers([void updates(ServerPlayersBuilder b)]) = _$ServerPlayers;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ServerPlayersBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ServerPlayers> get serializer => _$ServerPlayersSerializer();
}

class _$ServerPlayersSerializer implements PrimitiveSerializer<ServerPlayers> {
  @override
  final Iterable<Type> types = const [ServerPlayers, _$ServerPlayers];

  @override
  final String wireName = r'ServerPlayers';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ServerPlayers object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.max != null) {
      yield r'max';
      yield serializers.serialize(
        object.max,
        specifiedType: const FullType(int),
      );
    }
    if (object.count != null) {
      yield r'count';
      yield serializers.serialize(
        object.count,
        specifiedType: const FullType(int),
      );
    }
    if (object.list != null) {
      yield r'list';
      yield serializers.serialize(
        object.list,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ServerPlayers object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ServerPlayersBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'max':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.max = valueDes;
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        case r'list':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.list.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ServerPlayers deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ServerPlayersBuilder();
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

