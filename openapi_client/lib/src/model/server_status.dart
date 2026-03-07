//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'server_status.g.dart';

class ServerStatus extends EnumClass {

  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 0)
  static const ServerStatus OFFLINE = _$OFFLINE;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 1)
  static const ServerStatus ONLINE = _$ONLINE;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 2)
  static const ServerStatus STARTING = _$STARTING;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 3)
  static const ServerStatus STOPPING = _$STOPPING;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 4)
  static const ServerStatus RESTARTING = _$RESTARTING;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 5)
  static const ServerStatus SAVING = _$SAVING;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 6)
  static const ServerStatus LOADING = _$LOADING;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 7)
  static const ServerStatus CRASHED = _$CRASHED;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 8)
  static const ServerStatus PENDING = _$PENDING;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 9)
  static const ServerStatus TRANSFERRING = _$TRANSFERRING;
  /// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
  @BuiltValueEnumConst(wireNumber: 10)
  static const ServerStatus PREPARING = _$PREPARING;

  static Serializer<ServerStatus> get serializer => _$serverStatusSerializer;

  const ServerStatus._(String name): super(name);

  static BuiltSet<ServerStatus> get values => _$values;
  static ServerStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ServerStatusMixin = Object with _$ServerStatusMixin;

