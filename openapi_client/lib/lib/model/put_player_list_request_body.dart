//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PutPlayerListRequestBody {
  /// Returns a new [PutPlayerListRequestBody] instance.
  PutPlayerListRequestBody({
    this.entries = const [],
  });

  List<String> entries;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PutPlayerListRequestBody &&
    _deepEquality.equals(other.entries, entries);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (entries.hashCode);

  @override
  String toString() => 'PutPlayerListRequestBody[entries=$entries]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'entries'] = this.entries;
    return json;
  }

  /// Returns a new [PutPlayerListRequestBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PutPlayerListRequestBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PutPlayerListRequestBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PutPlayerListRequestBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PutPlayerListRequestBody(
        entries: json[r'entries'] is Iterable
            ? (json[r'entries'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<PutPlayerListRequestBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PutPlayerListRequestBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PutPlayerListRequestBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PutPlayerListRequestBody> mapFromJson(dynamic json) {
    final map = <String, PutPlayerListRequestBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PutPlayerListRequestBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PutPlayerListRequestBody-objects as value to a dart map
  static Map<String, List<PutPlayerListRequestBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PutPlayerListRequestBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PutPlayerListRequestBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

