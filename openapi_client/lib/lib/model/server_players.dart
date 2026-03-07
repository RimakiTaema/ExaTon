//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ServerPlayers {
  /// Returns a new [ServerPlayers] instance.
  ServerPlayers({
    this.max,
    this.count,
    this.list = const [],
  });

  /// Maximum player count (slots)
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? max;

  /// Current player count
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? count;

  /// Current player list (not always available)
  List<String> list;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ServerPlayers &&
    other.max == max &&
    other.count == count &&
    _deepEquality.equals(other.list, list);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (max == null ? 0 : max!.hashCode) +
    (count == null ? 0 : count!.hashCode) +
    (list.hashCode);

  @override
  String toString() => 'ServerPlayers[max=$max, count=$count, list=$list]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.max != null) {
      json[r'max'] = this.max;
    } else {
      json[r'max'] = null;
    }
    if (this.count != null) {
      json[r'count'] = this.count;
    } else {
      json[r'count'] = null;
    }
      json[r'list'] = this.list;
    return json;
  }

  /// Returns a new [ServerPlayers] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ServerPlayers? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ServerPlayers[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ServerPlayers[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ServerPlayers(
        max: mapValueOfType<int>(json, r'max'),
        count: mapValueOfType<int>(json, r'count'),
        list: json[r'list'] is Iterable
            ? (json[r'list'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<ServerPlayers> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ServerPlayers>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ServerPlayers.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ServerPlayers> mapFromJson(dynamic json) {
    final map = <String, ServerPlayers>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ServerPlayers.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ServerPlayers-objects as value to a dart map
  static Map<String, List<ServerPlayers>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ServerPlayers>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ServerPlayers.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

