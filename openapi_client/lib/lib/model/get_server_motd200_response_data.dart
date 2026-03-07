//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetServerMotd200ResponseData {
  /// Returns a new [GetServerMotd200ResponseData] instance.
  GetServerMotd200ResponseData({
    this.motd,
  });

  /// The MOTD of the server
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? motd;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetServerMotd200ResponseData &&
    other.motd == motd;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (motd == null ? 0 : motd!.hashCode);

  @override
  String toString() => 'GetServerMotd200ResponseData[motd=$motd]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.motd != null) {
      json[r'motd'] = this.motd;
    } else {
      json[r'motd'] = null;
    }
    return json;
  }

  /// Returns a new [GetServerMotd200ResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetServerMotd200ResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetServerMotd200ResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetServerMotd200ResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetServerMotd200ResponseData(
        motd: mapValueOfType<String>(json, r'motd'),
      );
    }
    return null;
  }

  static List<GetServerMotd200ResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetServerMotd200ResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetServerMotd200ResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetServerMotd200ResponseData> mapFromJson(dynamic json) {
    final map = <String, GetServerMotd200ResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetServerMotd200ResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetServerMotd200ResponseData-objects as value to a dart map
  static Map<String, List<GetServerMotd200ResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetServerMotd200ResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetServerMotd200ResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

