//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credit_pool_member.g.dart';

/// CreditPoolMember
///
/// Properties:
/// * [account] - Unique account ID of the pool member
/// * [name] - Account name of the pool member
/// * [share] - Share of the credits in this pool that are owned by the account
/// * [credits] - Number of credits in the pool that are owned by the account
/// * [isOwner] - Whether the account is the owner of this credit pool
@BuiltValue()
abstract class CreditPoolMember implements Built<CreditPoolMember, CreditPoolMemberBuilder> {
  /// Unique account ID of the pool member
  @BuiltValueField(wireName: r'account')
  String? get account;

  /// Account name of the pool member
  @BuiltValueField(wireName: r'name')
  String? get name;

  /// Share of the credits in this pool that are owned by the account
  @BuiltValueField(wireName: r'share')
  double? get share;

  /// Number of credits in the pool that are owned by the account
  @BuiltValueField(wireName: r'credits')
  double? get credits;

  /// Whether the account is the owner of this credit pool
  @BuiltValueField(wireName: r'isOwner')
  bool? get isOwner;

  CreditPoolMember._();

  factory CreditPoolMember([void updates(CreditPoolMemberBuilder b)]) = _$CreditPoolMember;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreditPoolMemberBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreditPoolMember> get serializer => _$CreditPoolMemberSerializer();
}

class _$CreditPoolMemberSerializer implements PrimitiveSerializer<CreditPoolMember> {
  @override
  final Iterable<Type> types = const [CreditPoolMember, _$CreditPoolMember];

  @override
  final String wireName = r'CreditPoolMember';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreditPoolMember object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.account != null) {
      yield r'account';
      yield serializers.serialize(
        object.account,
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
    if (object.share != null) {
      yield r'share';
      yield serializers.serialize(
        object.share,
        specifiedType: const FullType(double),
      );
    }
    if (object.credits != null) {
      yield r'credits';
      yield serializers.serialize(
        object.credits,
        specifiedType: const FullType(double),
      );
    }
    if (object.isOwner != null) {
      yield r'isOwner';
      yield serializers.serialize(
        object.isOwner,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreditPoolMember object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreditPoolMemberBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'account':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.account = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'share':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.share = valueDes;
          break;
        case r'credits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.credits = valueDes;
          break;
        case r'isOwner':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isOwner = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreditPoolMember deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreditPoolMemberBuilder();
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

