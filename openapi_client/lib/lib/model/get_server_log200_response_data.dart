//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetServerLog200ResponseData {
  /// Returns a new [GetServerLog200ResponseData] instance.
  GetServerLog200ResponseData({
    this.content,
  });

  String? content;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetServerLog200ResponseData &&
    other.content == content;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (content == null ? 0 : content!.hashCode);

  @override
  String toString() => 'GetServerLog200ResponseData[content=$content]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.content != null) {
      json[r'content'] = this.content;
    } else {
      json[r'content'] = null;
    }
    return json;
  }

  /// Returns a new [GetServerLog200ResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetServerLog200ResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetServerLog200ResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetServerLog200ResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetServerLog200ResponseData(
        content: mapValueOfType<String>(json, r'content'),
      );
    }
    return null;
  }

  static List<GetServerLog200ResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetServerLog200ResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetServerLog200ResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetServerLog200ResponseData> mapFromJson(dynamic json) {
    final map = <String, GetServerLog200ResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetServerLog200ResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetServerLog200ResponseData-objects as value to a dart map
  static Map<String, List<GetServerLog200ResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetServerLog200ResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetServerLog200ResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

