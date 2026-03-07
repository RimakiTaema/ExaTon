//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Server {
  /// Returns a new [Server] instance.
  Server({
    this.id,
    this.name,
    this.address,
    this.motd,
    this.status,
    this.host,
    this.port,
    this.players,
    this.software,
    this.shared,
  });

  /// Unique server ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Server name
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// Full server address
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? address;

  /// The MOTD of the server
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? motd;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ServerStatus? status;

  /// Host machine the server is running on. Only available if the server is online.
  String? host;

  /// Port the server is listening on. Only available if the server is online.
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? port;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ServerPlayers? players;

  ServerSoftware? software;

  /// Whether the server is accessed via the Share Access feature
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? shared;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Server &&
    other.id == id &&
    other.name == name &&
    other.address == address &&
    other.motd == motd &&
    other.status == status &&
    other.host == host &&
    other.port == port &&
    other.players == players &&
    other.software == software &&
    other.shared == shared;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (address == null ? 0 : address!.hashCode) +
    (motd == null ? 0 : motd!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (host == null ? 0 : host!.hashCode) +
    (port == null ? 0 : port!.hashCode) +
    (players == null ? 0 : players!.hashCode) +
    (software == null ? 0 : software!.hashCode) +
    (shared == null ? 0 : shared!.hashCode);

  @override
  String toString() => 'Server[id=$id, name=$name, address=$address, motd=$motd, status=$status, host=$host, port=$port, players=$players, software=$software, shared=$shared]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.address != null) {
      json[r'address'] = this.address;
    } else {
      json[r'address'] = null;
    }
    if (this.motd != null) {
      json[r'motd'] = this.motd;
    } else {
      json[r'motd'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.host != null) {
      json[r'host'] = this.host;
    } else {
      json[r'host'] = null;
    }
    if (this.port != null) {
      json[r'port'] = this.port;
    } else {
      json[r'port'] = null;
    }
    if (this.players != null) {
      json[r'players'] = this.players;
    } else {
      json[r'players'] = null;
    }
    if (this.software != null) {
      json[r'software'] = this.software;
    } else {
      json[r'software'] = null;
    }
    if (this.shared != null) {
      json[r'shared'] = this.shared;
    } else {
      json[r'shared'] = null;
    }
    return json;
  }

  /// Returns a new [Server] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Server? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Server[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Server[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Server(
        id: mapValueOfType<String>(json, r'id'),
        name: mapValueOfType<String>(json, r'name'),
        address: mapValueOfType<String>(json, r'address'),
        motd: mapValueOfType<String>(json, r'motd'),
        status: ServerStatus.fromJson(json[r'status']),
        host: mapValueOfType<String>(json, r'host'),
        port: mapValueOfType<int>(json, r'port'),
        players: ServerPlayers.fromJson(json[r'players']),
        software: ServerSoftware.fromJson(json[r'software']),
        shared: mapValueOfType<bool>(json, r'shared'),
      );
    }
    return null;
  }

  static List<Server> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Server>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Server.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Server> mapFromJson(dynamic json) {
    final map = <String, Server>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Server.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Server-objects as value to a dart map
  static Map<String, List<Server>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Server>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Server.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

