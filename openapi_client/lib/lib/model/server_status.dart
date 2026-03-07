//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

/// Servers can have different numeric status codes. Depending on a server's status, only certain features might be available. Possible enum values:  * 0 = OFFLINE  * 1 = ONLINE  * 2 = STARTING  * 3 = STOPPING  * 4 = RESTARTING  * 5 = SAVING  * 6 = LOADING  * 7 = CRASHED  * 8 = PENDING  * 9 = TRANSFERRING  * 10 = PREPARING 
class ServerStatus {
  /// Instantiate a new enum with the provided [value].
  const ServerStatus._(this.value);

  /// The underlying value of this enum member.
  final int value;

  @override
  String toString() => value.toString();

  int toJson() => value;

  static const OFFLINE = ServerStatus._(0);
  static const ONLINE = ServerStatus._(1);
  static const STARTING = ServerStatus._(2);
  static const STOPPING = ServerStatus._(3);
  static const RESTARTING = ServerStatus._(4);
  static const SAVING = ServerStatus._(5);
  static const LOADING = ServerStatus._(6);
  static const CRASHED = ServerStatus._(7);
  static const PENDING = ServerStatus._(8);
  static const TRANSFERRING = ServerStatus._(9);
  static const PREPARING = ServerStatus._(10);

  /// List of all possible values in this [enum][ServerStatus].
  static const values = <ServerStatus>[
    OFFLINE,
    ONLINE,
    STARTING,
    STOPPING,
    RESTARTING,
    SAVING,
    LOADING,
    CRASHED,
    PENDING,
    TRANSFERRING,
    PREPARING,
  ];

  static ServerStatus? fromJson(dynamic value) => ServerStatusTypeTransformer().decode(value);

  static List<ServerStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ServerStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ServerStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ServerStatus] to int,
/// and [decode] dynamic data back to [ServerStatus].
class ServerStatusTypeTransformer {
  factory ServerStatusTypeTransformer() => _instance ??= const ServerStatusTypeTransformer._();

  const ServerStatusTypeTransformer._();

  int encode(ServerStatus data) => data.value;

  /// Decodes a [dynamic value][data] to a ServerStatus.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ServerStatus? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case 0: return ServerStatus.OFFLINE;
        case 1: return ServerStatus.ONLINE;
        case 2: return ServerStatus.STARTING;
        case 3: return ServerStatus.STOPPING;
        case 4: return ServerStatus.RESTARTING;
        case 5: return ServerStatus.SAVING;
        case 6: return ServerStatus.LOADING;
        case 7: return ServerStatus.CRASHED;
        case 8: return ServerStatus.PENDING;
        case 9: return ServerStatus.TRANSFERRING;
        case 10: return ServerStatus.PREPARING;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ServerStatusTypeTransformer] instance.
  static ServerStatusTypeTransformer? _instance;
}

