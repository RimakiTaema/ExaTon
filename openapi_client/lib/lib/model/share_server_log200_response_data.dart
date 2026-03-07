//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ShareServerLog200ResponseData {
  /// Returns a new [ShareServerLog200ResponseData] instance.
  ShareServerLog200ResponseData({
    this.id,
    this.url,
    this.raw,
  });

  /// ID on mclo.gs
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// URL to shared logs on mclo.gs
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? url;

  /// URL to api of mclo.gs
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? raw;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ShareServerLog200ResponseData &&
    other.id == id &&
    other.url == url &&
    other.raw == raw;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (url == null ? 0 : url!.hashCode) +
    (raw == null ? 0 : raw!.hashCode);

  @override
  String toString() => 'ShareServerLog200ResponseData[id=$id, url=$url, raw=$raw]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.url != null) {
      json[r'url'] = this.url;
    } else {
      json[r'url'] = null;
    }
    if (this.raw != null) {
      json[r'raw'] = this.raw;
    } else {
      json[r'raw'] = null;
    }
    return json;
  }

  /// Returns a new [ShareServerLog200ResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ShareServerLog200ResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ShareServerLog200ResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ShareServerLog200ResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ShareServerLog200ResponseData(
        id: mapValueOfType<String>(json, r'id'),
        url: mapValueOfType<String>(json, r'url'),
        raw: mapValueOfType<String>(json, r'raw'),
      );
    }
    return null;
  }

  static List<ShareServerLog200ResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ShareServerLog200ResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ShareServerLog200ResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ShareServerLog200ResponseData> mapFromJson(dynamic json) {
    final map = <String, ShareServerLog200ResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ShareServerLog200ResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ShareServerLog200ResponseData-objects as value to a dart map
  static Map<String, List<ShareServerLog200ResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ShareServerLog200ResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ShareServerLog200ResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

