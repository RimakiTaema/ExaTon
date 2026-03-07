//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreditPoolMember {
  /// Returns a new [CreditPoolMember] instance.
  CreditPoolMember({
    this.account,
    this.name,
    this.share,
    this.credits,
    this.isOwner,
  });

  /// Unique account ID of the pool member
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? account;

  /// Account name of the pool member
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// Share of the credits in this pool that are owned by the account
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? share;

  /// Number of credits in the pool that are owned by the account
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? credits;

  /// Whether the account is the owner of this credit pool
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isOwner;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreditPoolMember &&
    other.account == account &&
    other.name == name &&
    other.share == share &&
    other.credits == credits &&
    other.isOwner == isOwner;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (account == null ? 0 : account!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (share == null ? 0 : share!.hashCode) +
    (credits == null ? 0 : credits!.hashCode) +
    (isOwner == null ? 0 : isOwner!.hashCode);

  @override
  String toString() => 'CreditPoolMember[account=$account, name=$name, share=$share, credits=$credits, isOwner=$isOwner]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.account != null) {
      json[r'account'] = this.account;
    } else {
      json[r'account'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.share != null) {
      json[r'share'] = this.share;
    } else {
      json[r'share'] = null;
    }
    if (this.credits != null) {
      json[r'credits'] = this.credits;
    } else {
      json[r'credits'] = null;
    }
    if (this.isOwner != null) {
      json[r'isOwner'] = this.isOwner;
    } else {
      json[r'isOwner'] = null;
    }
    return json;
  }

  /// Returns a new [CreditPoolMember] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreditPoolMember? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreditPoolMember[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreditPoolMember[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreditPoolMember(
        account: mapValueOfType<String>(json, r'account'),
        name: mapValueOfType<String>(json, r'name'),
        share: mapValueOfType<double>(json, r'share'),
        credits: mapValueOfType<double>(json, r'credits'),
        isOwner: mapValueOfType<bool>(json, r'isOwner'),
      );
    }
    return null;
  }

  static List<CreditPoolMember> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreditPoolMember>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreditPoolMember.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreditPoolMember> mapFromJson(dynamic json) {
    final map = <String, CreditPoolMember>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreditPoolMember.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreditPoolMember-objects as value to a dart map
  static Map<String, List<CreditPoolMember>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreditPoolMember>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreditPoolMember.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

