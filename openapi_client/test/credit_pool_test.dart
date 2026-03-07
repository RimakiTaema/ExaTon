import 'package:test/test.dart';
import 'package:openapi/openapi.dart';

// tests for CreditPool
void main() {
  final instance = CreditPoolBuilder();
  // TODO add properties to the builder and call build()

  group(CreditPool, () {
    // Unique credit pool ID
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // Credit pool name
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Credits in this credit pool
    // double credits
    test('to test the property `credits`', () async {
      // TODO
    });

    // Number of servers in this credit pool
    // int servers
    test('to test the property `servers`', () async {
      // TODO
    });

    // Unique account ID of the pool owner
    // String owner
    test('to test the property `owner`', () async {
      // TODO
    });

    // Whether the current user is the owner of this credit pool
    // bool isOwner
    test('to test the property `isOwner`', () async {
      // TODO
    });

    // Number of members in this credit pool
    // int members
    test('to test the property `members`', () async {
      // TODO
    });

    // Share of the credits in this pool that are owned by the current user
    // double ownShare
    test('to test the property `ownShare`', () async {
      // TODO
    });

    // Number of credits in the pool that are owned by the current user
    // double ownCredits
    test('to test the property `ownCredits`', () async {
      // TODO
    });

  });
}
