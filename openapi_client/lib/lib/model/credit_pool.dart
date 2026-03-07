//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreditPool {
  /// Returns a new [CreditPool] instance.
  CreditPool({
    this.id,
    this.name,
    this.credits,
    this.servers,
    this.owner,
    this.isOwner,
    this.members,
    this.ownShare,
    this.ownCredits,
  });

  /// Unique credit pool ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  /// Credit pool name
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// Credits in this credit pool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? credits;

  /// Number of servers in this credit pool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? servers;

  /// Unique account ID of the pool owner
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? owner;

  /// Whether the current user is the owner of this credit pool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isOwner;

  /// Number of members in this credit pool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? members;

  /// Share of the credits in this pool that are owned by the current user
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? ownShare;

  /// Number of credits in the pool that are owned by the current user
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? ownCredits;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreditPool &&
    other.id == id &&
    other.name == name &&
    other.credits == credits &&
    other.servers == servers &&
    other.owner == owner &&
    other.isOwner == isOwner &&
    other.members == members &&
    other.ownShare == ownShare &&
    other.ownCredits == ownCredits;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (credits == null ? 0 : credits!.hashCode) +
    (servers == null ? 0 : servers!.hashCode) +
    (owner == null ? 0 : owner!.hashCode) +
    (isOwner == null ? 0 : isOwner!.hashCode) +
    (members == null ? 0 : members!.hashCode) +
    (ownShare == null ? 0 : ownShare!.hashCode) +
    (ownCredits == null ? 0 : ownCredits!.hashCode);

  @override
  String toString() => 'CreditPool[id=$id, name=$name, credits=$credits, servers=$servers, owner=$owner, isOwner=$isOwner, members=$members, ownShare=$ownShare, ownCredits=$ownCredits]';

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
    if (this.credits != null) {
      json[r'credits'] = this.credits;
    } else {
      json[r'credits'] = null;
    }
    if (this.servers != null) {
      json[r'servers'] = this.servers;
    } else {
      json[r'servers'] = null;
    }
    if (this.owner != null) {
      json[r'owner'] = this.owner;
    } else {
      json[r'owner'] = null;
    }
    if (this.isOwner != null) {
      json[r'isOwner'] = this.isOwner;
    } else {
      json[r'isOwner'] = null;
    }
    if (this.members != null) {
      json[r'members'] = this.members;
    } else {
      json[r'members'] = null;
    }
    if (this.ownShare != null) {
      json[r'ownShare'] = this.ownShare;
    } else {
      json[r'ownShare'] = null;
    }
    if (this.ownCredits != null) {
      json[r'ownCredits'] = this.ownCredits;
    } else {
      json[r'ownCredits'] = null;
    }
    return json;
  }

  /// Returns a new [CreditPool] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreditPool? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreditPool[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreditPool[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreditPool(
        id: mapValueOfType<String>(json, r'id'),
        name: mapValueOfType<String>(json, r'name'),
        credits: mapValueOfType<double>(json, r'credits'),
        servers: mapValueOfType<int>(json, r'servers'),
        owner: mapValueOfType<String>(json, r'owner'),
        isOwner: mapValueOfType<bool>(json, r'isOwner'),
        members: mapValueOfType<int>(json, r'members'),
        ownShare: mapValueOfType<double>(json, r'ownShare'),
        ownCredits: mapValueOfType<double>(json, r'ownCredits'),
      );
    }
    return null;
  }

  static List<CreditPool> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreditPool>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreditPool.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreditPool> mapFromJson(dynamic json) {
    final map = <String, CreditPool>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreditPool.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreditPool-objects as value to a dart map
  static Map<String, List<CreditPool>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreditPool>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreditPool.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

