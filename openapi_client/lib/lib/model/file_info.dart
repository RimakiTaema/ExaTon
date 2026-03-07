//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FileInfo {
  /// Returns a new [FileInfo] instance.
  FileInfo({
    this.path,
    this.name,
    this.isTextFile,
    this.isConfigFile,
    this.isDirectory,
    this.isLog,
    this.isReadable,
    this.isWritable,
    this.size,
    this.children = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? path;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isTextFile;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isConfigFile;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isDirectory;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isLog;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isReadable;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isWritable;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? size;

  List<FileInfo>? children;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FileInfo &&
    other.path == path &&
    other.name == name &&
    other.isTextFile == isTextFile &&
    other.isConfigFile == isConfigFile &&
    other.isDirectory == isDirectory &&
    other.isLog == isLog &&
    other.isReadable == isReadable &&
    other.isWritable == isWritable &&
    other.size == size &&
    _deepEquality.equals(other.children, children);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (path == null ? 0 : path!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (isTextFile == null ? 0 : isTextFile!.hashCode) +
    (isConfigFile == null ? 0 : isConfigFile!.hashCode) +
    (isDirectory == null ? 0 : isDirectory!.hashCode) +
    (isLog == null ? 0 : isLog!.hashCode) +
    (isReadable == null ? 0 : isReadable!.hashCode) +
    (isWritable == null ? 0 : isWritable!.hashCode) +
    (size == null ? 0 : size!.hashCode) +
    (children == null ? 0 : children!.hashCode);

  @override
  String toString() => 'FileInfo[path=$path, name=$name, isTextFile=$isTextFile, isConfigFile=$isConfigFile, isDirectory=$isDirectory, isLog=$isLog, isReadable=$isReadable, isWritable=$isWritable, size=$size, children=$children]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.path != null) {
      json[r'path'] = this.path;
    } else {
      json[r'path'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.isTextFile != null) {
      json[r'isTextFile'] = this.isTextFile;
    } else {
      json[r'isTextFile'] = null;
    }
    if (this.isConfigFile != null) {
      json[r'isConfigFile'] = this.isConfigFile;
    } else {
      json[r'isConfigFile'] = null;
    }
    if (this.isDirectory != null) {
      json[r'isDirectory'] = this.isDirectory;
    } else {
      json[r'isDirectory'] = null;
    }
    if (this.isLog != null) {
      json[r'isLog'] = this.isLog;
    } else {
      json[r'isLog'] = null;
    }
    if (this.isReadable != null) {
      json[r'isReadable'] = this.isReadable;
    } else {
      json[r'isReadable'] = null;
    }
    if (this.isWritable != null) {
      json[r'isWritable'] = this.isWritable;
    } else {
      json[r'isWritable'] = null;
    }
    if (this.size != null) {
      json[r'size'] = this.size;
    } else {
      json[r'size'] = null;
    }
    if (this.children != null) {
      json[r'children'] = this.children;
    } else {
      json[r'children'] = null;
    }
    return json;
  }

  /// Returns a new [FileInfo] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FileInfo? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FileInfo[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FileInfo[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FileInfo(
        path: mapValueOfType<String>(json, r'path'),
        name: mapValueOfType<String>(json, r'name'),
        isTextFile: mapValueOfType<bool>(json, r'isTextFile'),
        isConfigFile: mapValueOfType<bool>(json, r'isConfigFile'),
        isDirectory: mapValueOfType<bool>(json, r'isDirectory'),
        isLog: mapValueOfType<bool>(json, r'isLog'),
        isReadable: mapValueOfType<bool>(json, r'isReadable'),
        isWritable: mapValueOfType<bool>(json, r'isWritable'),
        size: mapValueOfType<int>(json, r'size'),
        children: FileInfo.listFromJson(json[r'children']),
      );
    }
    return null;
  }

  static List<FileInfo> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FileInfo>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FileInfo.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FileInfo> mapFromJson(dynamic json) {
    final map = <String, FileInfo>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FileInfo.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FileInfo-objects as value to a dart map
  static Map<String, List<FileInfo>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FileInfo>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FileInfo.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

