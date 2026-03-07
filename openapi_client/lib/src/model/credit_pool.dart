//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credit_pool.g.dart';

/// CreditPool
///
/// Properties:
/// * [id] - Unique credit pool ID
/// * [name] - Credit pool name
/// * [credits] - Credits in this credit pool
/// * [servers] - Number of servers in this credit pool
/// * [owner] - Unique account ID of the pool owner
/// * [isOwner] - Whether the current user is the owner of this credit pool
/// * [members] - Number of members in this credit pool
/// * [ownShare] - Share of the credits in this pool that are owned by the current user
/// * [ownCredits] - Number of credits in the pool that are owned by the current user
@BuiltValue()
abstract class CreditPool implements Built<CreditPool, CreditPoolBuilder> {
  /// Unique credit pool ID
  @BuiltValueField(wireName: r'id')
  String? get id;

  /// Credit pool name
  @BuiltValueField(wireName: r'name')
  String? get name;

  /// Credits in this credit pool
  @BuiltValueField(wireName: r'credits')
  double? get credits;

  /// Number of servers in this credit pool
  @BuiltValueField(wireName: r'servers')
  int? get servers;

  /// Unique account ID of the pool owner
  @BuiltValueField(wireName: r'owner')
  String? get owner;

  /// Whether the current user is the owner of this credit pool
  @BuiltValueField(wireName: r'isOwner')
  bool? get isOwner;

  /// Number of members in this credit pool
  @BuiltValueField(wireName: r'members')
  int? get members;

  /// Share of the credits in this pool that are owned by the current user
  @BuiltValueField(wireName: r'ownShare')
  double? get ownShare;

  /// Number of credits in the pool that are owned by the current user
  @BuiltValueField(wireName: r'ownCredits')
  double? get ownCredits;

  CreditPool._();

  factory CreditPool([void updates(CreditPoolBuilder b)]) = _$CreditPool;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreditPoolBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreditPool> get serializer => _$CreditPoolSerializer();
}

class _$CreditPoolSerializer implements PrimitiveSerializer<CreditPool> {
  @override
  final Iterable<Type> types = const [CreditPool, _$CreditPool];

  @override
  final String wireName = r'CreditPool';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreditPool object, {
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
    if (object.credits != null) {
      yield r'credits';
      yield serializers.serialize(
        object.credits,
        specifiedType: const FullType(double),
      );
    }
    if (object.servers != null) {
      yield r'servers';
      yield serializers.serialize(
        object.servers,
        specifiedType: const FullType(int),
      );
    }
    if (object.owner != null) {
      yield r'owner';
      yield serializers.serialize(
        object.owner,
        specifiedType: const FullType(String),
      );
    }
    if (object.isOwner != null) {
      yield r'isOwner';
      yield serializers.serialize(
        object.isOwner,
        specifiedType: const FullType(bool),
      );
    }
    if (object.members != null) {
      yield r'members';
      yield serializers.serialize(
        object.members,
        specifiedType: const FullType(int),
      );
    }
    if (object.ownShare != null) {
      yield r'ownShare';
      yield serializers.serialize(
        object.ownShare,
        specifiedType: const FullType(double),
      );
    }
    if (object.ownCredits != null) {
      yield r'ownCredits';
      yield serializers.serialize(
        object.ownCredits,
        specifiedType: const FullType(double),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreditPool object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreditPoolBuilder result,
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
        case r'credits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.credits = valueDes;
          break;
        case r'servers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.servers = valueDes;
          break;
        case r'owner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.owner = valueDes;
          break;
        case r'isOwner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isOwner = valueDes;
          break;
        case r'members':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.members = valueDes;
          break;
        case r'ownShare':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.ownShare = valueDes;
          break;
        case r'ownCredits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.ownCredits = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreditPool deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreditPoolBuilder();
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

