import 'package:exaton/core/exaroton/client.dart';
import 'package:exaton/core/exaroton/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';

void main() {
  group('ExarotonClient', () {
    test('sends the bearer token and unwraps the envelope', () async {
      final api = FakeAdapter({'GET /account/': (200, fixture('account'))});
      final account = await fakeClient(api, 'secret').getAccount();
      expect(account.name, 'Main');
      expect(account.credits, 1248.5);
      expect(account.verified, isTrue);
      expect(api.requests.single.headers['Authorization'], 'Bearer secret');
    });

    test('parses servers, status codes and groups', () async {
      final api = FakeAdapter({'GET /servers/': (200, fixture('servers'))});
      final servers = await fakeClient(api).getServers();
      expect(servers.map((s) => s.status), [ServerStatus.online, ServerStatus.starting, ServerStatus.offline]);
      expect(servers.map((s) => s.status.group), [StatusGroup.online, StatusGroup.busy, StatusGroup.offline]);
      expect(servers.first.players.list, ['Steve', 'Kai', 'Mira', 'Lio']);
      expect(servers.first.software.toString(), 'Paper 1.21');
      expect(servers[2].shared, isTrue);
      expect(servers[2].allows('console'), isTrue);
      expect(servers[2].allows('config'), isFalse);
      expect(servers.first.allows('config'), isTrue, reason: 'own servers allow everything');
    });

    test('208 on start means already starting, not an error', () async {
      final api = FakeAdapter({'GET /servers/abc/start/': (208, fixture('already_starting'))});
      expect(await fakeClient(api).start('abc'), ActionResult.alreadyInProgress);
    });

    test('208 on stop means already stopping', () async {
      final api = FakeAdapter({'GET /servers/abc/stop/': (208, fixture('already_starting'))});
      expect(await fakeClient(api).stop('abc'), ActionResult.alreadyInProgress);
    });

    test('start with own credits posts useOwnCredits', () async {
      final api = FakeAdapter({'POST /servers/abc/start/': (200, ok(null))});
      expect(await fakeClient(api).start('abc', useOwnCredits: true), ActionResult.accepted);
      expect(api.requests.single.data, {'useOwnCredits': true});
    });

    test('403 on pool members surfaces as forbidden', () async {
      final api = FakeAdapter({'GET /billing/pools/p1/members/': (403, fixture('forbidden'))});
      await expectLater(
        fakeClient(api).getPoolMembers('p1'),
        throwsA(
          isA<ExarotonException>()
              .having((e) => e.isForbidden, 'isForbidden', isTrue)
              .having((e) => e.message, 'message', contains('permission')),
        ),
      );
    });

    test('413 on file write surfaces as too large', () async {
      final api = FakeAdapter({'PUT /servers/abc/files/data/world/big.dat/': (413, '<html>Too Large</html>')});
      await expectLater(
        fakeClient(api).writeFile('abc', 'world/big.dat', List.filled(10, 0)),
        throwsA(isA<ExarotonException>().having((e) => e.isTooLarge, 'isTooLarge', isTrue)),
      );
    });

    test('envelope success:false with 200 is still an error', () async {
      final api = FakeAdapter({'GET /account/': (200, apiError('Invalid API token'))});
      await expectLater(fakeClient(api).getAccount(), throwsA(isA<ExarotonException>()));
    });

    test('file paths are encoded per segment; root has no double slash', () async {
      final api = FakeAdapter({
        'GET /servers/abc/files/info/': (200, ok({'path': '/', 'name': '', 'isDirectory': true, 'children': []})),
        'GET /servers/abc/files/info/plugins/My%20Plugin/': (
          200,
          ok({'path': 'plugins/My Plugin', 'isDirectory': true}),
        ),
      });
      final c = fakeClient(api);
      expect((await c.getFileInfo('abc', '')).isDirectory, isTrue);
      expect((await c.getFileInfo('abc', '/plugins/My Plugin/')).path, 'plugins/My Plugin');
    });

    test('creating a folder sends inode/directory', () async {
      final api = FakeAdapter({'PUT /servers/abc/files/data/newdir/': (200, ok(null))});
      await fakeClient(api).createDirectory('abc', 'newdir');
      expect(api.requests.single.contentType, 'inode/directory');
    });

    test('config options keep their types and ranges', () async {
      final api = FakeAdapter({'GET /servers/abc/files/config/server.properties/': (200, fixture('config'))});
      final opts = await fakeClient(api).getConfig('abc', 'server.properties');
      expect(opts.map((o) => o.type), [
        ConfigOptionType.integer,
        ConfigOptionType.select,
        ConfigOptionType.boolean,
        ConfigOptionType.string,
      ]);
      expect(opts.first.min, 1);
      expect(opts.first.max, 1000);
      expect(opts[1].options, contains('creative'));
    });

    test('RAM outside 2 to 16 GB is rejected before calling the API', () {
      final api = FakeAdapter({});
      expect(() => fakeClient(api).setRam('abc', 1), throwsArgumentError);
      expect(() => fakeClient(api).setRam('abc', 17), throwsArgumentError);
      expect(api.requests, isEmpty);
    });

    test('pools and members parse', () async {
      final api = FakeAdapter(standardRoutes());
      final c = fakeClient(api);
      final pools = await c.getPools();
      expect(pools.single.name, 'Friends SMP pool');
      expect(pools.single.ownShare, 0.45);
      final members = await c.getPoolMembers(pools.single.id);
      expect(members.map((m) => m.name), ['Main', 'Kai', 'Rin']);
    });
  });

  group('Software', () {
    test('tick needs Java 1.16 or later', () {
      expect(const Software(id: '', name: 'Paper', version: '1.21').supportsTick, isTrue);
      expect(const Software(id: '', name: 'Vanilla', version: '1.16.5').supportsTick, isTrue);
      expect(const Software(id: '', name: 'Forge', version: '1.12.2').supportsTick, isFalse);
      expect(const Software(id: '', name: 'Bedrock', version: '1.21.0').supportsTick, isFalse);
      expect(const Software(id: '', name: 'Bedrock', version: '1.21.0').isJava, isFalse);
    });
  });
}
