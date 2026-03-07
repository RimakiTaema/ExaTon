// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ServerStatus _$OFFLINE = const ServerStatus._('OFFLINE');
const ServerStatus _$ONLINE = const ServerStatus._('ONLINE');
const ServerStatus _$STARTING = const ServerStatus._('STARTING');
const ServerStatus _$STOPPING = const ServerStatus._('STOPPING');
const ServerStatus _$RESTARTING = const ServerStatus._('RESTARTING');
const ServerStatus _$SAVING = const ServerStatus._('SAVING');
const ServerStatus _$LOADING = const ServerStatus._('LOADING');
const ServerStatus _$CRASHED = const ServerStatus._('CRASHED');
const ServerStatus _$PENDING = const ServerStatus._('PENDING');
const ServerStatus _$TRANSFERRING = const ServerStatus._('TRANSFERRING');
const ServerStatus _$PREPARING = const ServerStatus._('PREPARING');

ServerStatus _$valueOf(String name) {
  switch (name) {
    case 'OFFLINE':
      return _$OFFLINE;
    case 'ONLINE':
      return _$ONLINE;
    case 'STARTING':
      return _$STARTING;
    case 'STOPPING':
      return _$STOPPING;
    case 'RESTARTING':
      return _$RESTARTING;
    case 'SAVING':
      return _$SAVING;
    case 'LOADING':
      return _$LOADING;
    case 'CRASHED':
      return _$CRASHED;
    case 'PENDING':
      return _$PENDING;
    case 'TRANSFERRING':
      return _$TRANSFERRING;
    case 'PREPARING':
      return _$PREPARING;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ServerStatus> _$values =
    BuiltSet<ServerStatus>(const <ServerStatus>[
  _$OFFLINE,
  _$ONLINE,
  _$STARTING,
  _$STOPPING,
  _$RESTARTING,
  _$SAVING,
  _$LOADING,
  _$CRASHED,
  _$PENDING,
  _$TRANSFERRING,
  _$PREPARING,
]);

class _$ServerStatusMeta {
  const _$ServerStatusMeta();
  ServerStatus get OFFLINE => _$OFFLINE;
  ServerStatus get ONLINE => _$ONLINE;
  ServerStatus get STARTING => _$STARTING;
  ServerStatus get STOPPING => _$STOPPING;
  ServerStatus get RESTARTING => _$RESTARTING;
  ServerStatus get SAVING => _$SAVING;
  ServerStatus get LOADING => _$LOADING;
  ServerStatus get CRASHED => _$CRASHED;
  ServerStatus get PENDING => _$PENDING;
  ServerStatus get TRANSFERRING => _$TRANSFERRING;
  ServerStatus get PREPARING => _$PREPARING;
  ServerStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ServerStatus> get values => _$values;
}

abstract class _$ServerStatusMixin {
  // ignore: non_constant_identifier_names
  _$ServerStatusMeta get ServerStatus => const _$ServerStatusMeta();
}

Serializer<ServerStatus> _$serverStatusSerializer = _$ServerStatusSerializer();

class _$ServerStatusSerializer implements PrimitiveSerializer<ServerStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'OFFLINE': 0,
    'ONLINE': 1,
    'STARTING': 2,
    'STOPPING': 3,
    'RESTARTING': 4,
    'SAVING': 5,
    'LOADING': 6,
    'CRASHED': 7,
    'PENDING': 8,
    'TRANSFERRING': 9,
    'PREPARING': 10,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    0: 'OFFLINE',
    1: 'ONLINE',
    2: 'STARTING',
    3: 'STOPPING',
    4: 'RESTARTING',
    5: 'SAVING',
    6: 'LOADING',
    7: 'CRASHED',
    8: 'PENDING',
    9: 'TRANSFERRING',
    10: 'PREPARING',
  };

  @override
  final Iterable<Type> types = const <Type>[ServerStatus];
  @override
  final String wireName = 'ServerStatus';

  @override
  Object serialize(Serializers serializers, ServerStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ServerStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ServerStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
