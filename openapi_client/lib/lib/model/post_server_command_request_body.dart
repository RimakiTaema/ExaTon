//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PostServerCommandRequestBody {
  /// Returns a new [PostServerCommandRequestBody] instance.
  PostServerCommandRequestBody({
    this.command,
  });

  /// The command to send to the server
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? command;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PostServerCommandRequestBody &&
    other.command == command;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (command == null ? 0 : command!.hashCode);

  @override
  String toString() => 'PostServerCommandRequestBody[command=$command]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.command != null) {
      json[r'command'] = this.command;
    } else {
      json[r'command'] = null;
    }
    return json;
  }

  /// Returns a new [PostServerCommandRequestBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PostServerCommandRequestBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PostServerCommandRequestBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PostServerCommandRequestBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PostServerCommandRequestBody(
        command: mapValueOfType<String>(json, r'command'),
      );
    }
    return null;
  }

  static List<PostServerCommandRequestBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PostServerCommandRequestBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PostServerCommandRequestBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PostServerCommandRequestBody> mapFromJson(dynamic json) {
    final map = <String, PostServerCommandRequestBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PostServerCommandRequestBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PostServerCommandRequestBody-objects as value to a dart map
  static Map<String, List<PostServerCommandRequestBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PostServerCommandRequestBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PostServerCommandRequestBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

