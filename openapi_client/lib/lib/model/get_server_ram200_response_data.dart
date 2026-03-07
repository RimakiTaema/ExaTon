//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetServerRam200ResponseData {
  /// Returns a new [GetServerRam200ResponseData] instance.
  GetServerRam200ResponseData({
    this.ram,
  });

  /// How many GB ram this server has
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ram;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetServerRam200ResponseData &&
    other.ram == ram;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (ram == null ? 0 : ram!.hashCode);

  @override
  String toString() => 'GetServerRam200ResponseData[ram=$ram]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.ram != null) {
      json[r'ram'] = this.ram;
    } else {
      json[r'ram'] = null;
    }
    return json;
  }

  /// Returns a new [GetServerRam200ResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetServerRam200ResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetServerRam200ResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetServerRam200ResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetServerRam200ResponseData(
        ram: mapValueOfType<int>(json, r'ram'),
      );
    }
    return null;
  }

  static List<GetServerRam200ResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetServerRam200ResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetServerRam200ResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetServerRam200ResponseData> mapFromJson(dynamic json) {
    final map = <String, GetServerRam200ResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetServerRam200ResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetServerRam200ResponseData-objects as value to a dart map
  static Map<String, List<GetServerRam200ResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetServerRam200ResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetServerRam200ResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

