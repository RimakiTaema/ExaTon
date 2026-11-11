import 'package:exaton/core/exaroton/models.dart';
import 'package:exaton/features/servers/access_tab.dart';
import 'package:flutter_test/flutter_test.dart';

Server server({bool shared = true, List<String>? permissions}) => Server.fromJson({
  'id': 'Srv0000000000001',
  'name': 'Survival',
  'address': 's.exaroton.me',
  'status': 0,
  'players': {'max': 20, 'count': 0},
  'software': {'id': 'sw', 'name': 'Paper', 'version': '1.21', 'type': 'paper'},
  'shared': shared,
  'permissions': permissions,
});

bool allowed(Server s, String label) => accessFeatures(s).firstWhere((f) => f.label == label).allowed;

void main() {
  test('Software can be granted through Share Access; delete cannot', () {
    final s = server(permissions: ['software', 'config']);
    expect(allowed(s, 'Software'), isTrue);
    expect(allowed(s, 'Config'), isTrue);
    expect(allowed(s, 'Delete server'), isFalse);
    expect(describePermission('software'), 'Change the server software');
  });

  test('without the grant, a shared account cannot change software', () {
    final s = server(permissions: ['console']);
    expect(allowed(s, 'Software'), isFalse);
    expect(allowed(s, 'Delete server'), isFalse);
  });

  test('the owner has both', () {
    final s = server(shared: false);
    expect(allowed(s, 'Software'), isTrue);
    expect(allowed(s, 'Delete server'), isTrue);
  });
}
