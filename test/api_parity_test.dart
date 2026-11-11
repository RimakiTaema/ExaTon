import 'package:exaton/core/exaroton/client.dart';
import 'package:exaton/core/exaroton/models.dart';
import 'package:exaton/features/servers/server_form.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';

void main() {
  group('account and server models', () {
    test('account carries id and maxServers; both are optional', () async {
      final api = FakeAdapter({'GET /account/': (200, fixture('account_max_servers'))});
      final a = await fakeClient(api).getAccount();
      expect(a.id, 'Acc0000000000001');
      expect(a.maxServers, 10);

      final old = FakeAdapter({'GET /account/': (200, fixture('account'))});
      expect((await fakeClient(old).getAccount()).maxServers, isNull);
    });

    test('a shared server lists its permissions and is not owned', () async {
      final api = FakeAdapter({'GET /servers/Srv0000000000009/': (200, fixture('server_shared'))});
      final s = await fakeClient(api).getServer('Srv0000000000009');
      expect(s.shared, isTrue);
      expect(s.permissions, ['console', 'players']);
      expect(s.isOwner, isFalse);
      expect(s.allows('console'), isTrue);
      expect(s.allows('player'), isTrue);
      expect(s.allows('file'), isFalse);
      expect(s.software!.addons, ['plugin']);
      expect(s.software!.type, 'paper');
    });

    test('null permissions mean the owner, who may do everything', () async {
      final api = FakeAdapter({'GET /servers/Srv0000000000010/': (200, fixture('server_created'))});
      final s = await fakeClient(api).getServer('Srv0000000000010');
      expect(s.permissions, isNull);
      expect(s.isOwner, isTrue);
      expect(s.allows('file'), isTrue);
    });

    test('software without addons parses, as in the older shape', () async {
      final api = FakeAdapter({'GET /servers/': (200, fixture('servers'))});
      final s = (await fakeClient(api).getServers()).first;
      expect(s.software!.addons, isNull);
      expect(s.software.toString(), 'Paper 1.21');
    });
  });

  group('create server', () {
    test('posts the body without empty optional fields and returns the server', () async {
      final api = FakeAdapter({'POST /servers/': (200, fixture('server_created'))});
      final s = await fakeClient(api).createServer(
        const CreateServerRequest(name: ' example ', softwareType: 'vanilla', motd: '', timezone: '  ', region: 'eu'),
      );
      expect(s.id, 'Srv0000000000010');
      expect(api.requests.single.data, {'name': 'example', 'softwareType': 'vanilla', 'region': 'eu'});
    });

    test('an unknown region is left out', () {
      expect(const CreateServerRequest(name: 'a', software: 'SwVanilla0001210', region: 'asia').toJson(), {
        'name': 'a',
        'software': 'SwVanilla0001210',
      });
    });

    test('413 is the server limit, worded with maxServers when known', () async {
      final api = FakeAdapter({'POST /servers/': (413, fixture('server_limit'))});
      Object? caught;
      try {
        await fakeClient(api).createServer(const CreateServerRequest(name: 'x', softwareType: 'vanilla'));
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<ServerLimitReachedException>());
      expect((caught! as ExarotonException).statusCode, 413);
      expect(createServerError(caught, maxServers: 10), 'Server limit reached (10 max)');
      expect(createServerError(caught), 'Server limit reached');
    });

    test('413 from a proxy without a JSON body is still the server limit', () async {
      final api = FakeAdapter({'POST /servers/': (413, '<html>nope</html>')});
      await expectLater(
        fakeClient(api).createServer(const CreateServerRequest(name: 'x', softwareType: 'vanilla')),
        throwsA(isA<ServerLimitReachedException>().having((e) => e.message, 'message', 'Server limit reached')),
      );
    });

    test('400 keeps the API error text', () async {
      final api = FakeAdapter({'POST /servers/': (400, apiError('Invalid software'))});
      Object? caught;
      try {
        await fakeClient(api).createServer(const CreateServerRequest(name: 'x', software: 'nope'));
      } catch (e) {
        caught = e;
      }
      expect(caught, isNot(isA<ServerLimitReachedException>()));
      expect(createServerError(caught!), 'Invalid software');
    });
  });

  group('delete server', () {
    test('sends DELETE to the server path', () async {
      final api = FakeAdapter({'DELETE /servers/Srv0000000000010/': (200, ok(null))});
      await fakeClient(api).deleteServer('Srv0000000000010');
      expect(api.requests.single.method, 'DELETE');
    });

    test('403 for a shared server surfaces as forbidden', () async {
      final api = FakeAdapter({'DELETE /servers/abc/': (403, fixture('forbidden'))});
      await expectLater(
        fakeClient(api).deleteServer('abc'),
        throwsA(isA<ExarotonException>().having((e) => e.isForbidden, 'isForbidden', isTrue)),
      );
    });

    test('400 for a running server keeps the API reason', () async {
      final api = FakeAdapter({'DELETE /servers/abc/': (400, fixture('bad_request'))});
      await expectLater(
        fakeClient(api).deleteServer('abc'),
        throwsA(
          isA<ExarotonException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('offline')),
        ),
      );
    });
  });

  group('software', () {
    test('list parses and passes the filters as query parameters', () async {
      final api = FakeAdapter({'GET /software/': (200, fixture('software_list'))});
      final list = await fakeClient(api).listSoftware(type: 'modpack', launcher: 'CurseForge');
      expect(list, hasLength(4));
      expect(list.last.launcher, 'CurseForge');
      expect(list.first.launcher, isNull);
      expect(api.requests.single.uri.queryParameters, {'type': 'modpack', 'launcher': 'CurseForge'});
    });

    test('no filters means no query', () async {
      final api = FakeAdapter({'GET /software/': (200, fixture('software_list'))});
      await fakeClient(api).listSoftware();
      expect(api.requests.single.uri.queryParameters, isEmpty);
    });

    test('details carry description, link, addons and the reinstall flag', () async {
      final api = FakeAdapter({'GET /servers/abc/software/SwPack0000000001/': (200, fixture('software_details'))});
      final d = await fakeClient(api).getServerSoftware('abc', 'SwPack0000000001');
      expect(d.reinstall, isTrue);
      expect(d.addons, ['mod']);
      expect(d.description, contains('modpack'));
      expect(d.link, startsWith('https://'));
    });

    test('install confirms a reinstall only when asked', () async {
      final api = FakeAdapter({'POST /servers/abc/software/sw1/': (200, ok(null))});
      final c = fakeClient(api);
      await c.installSoftware('abc', 'sw1');
      await c.installSoftware('abc', 'sw1', reinstall: true);
      expect(api.requests[0].data, isEmpty);
      expect(api.requests[1].data, {'reinstall': true});
    });

    test('install without the confirmation surfaces the 400', () async {
      final api = FakeAdapter({'POST /servers/abc/software/sw1/': (400, apiError('Reinstall required'))});
      await expectLater(
        fakeClient(api).installSoftware('abc', 'sw1'),
        throwsA(isA<ExarotonException>().having((e) => e.message, 'message', 'Reinstall required')),
      );
    });

    test('picker helpers: types in order, filter by type and search', () async {
      final api = FakeAdapter({'GET /software/': (200, fixture('software_list'))});
      final list = await fakeClient(api).listSoftware();
      expect(softwareTypes(list), ['vanilla', 'paper', 'modpack']);
      expect(filterSoftware(list, type: 'vanilla').map((s) => s.version), ['1.20.4', '1.21']);
      expect(filterSoftware(list, query: 'curseforge').single.name, 'All the Mods 9');
      expect(filterSoftware(list, query: '1.21').map((s) => s.name), ['Vanilla', 'Paper']);
      expect(filterSoftware(list, type: 'paper', query: 'vanilla'), isEmpty);
    });

    test('custom software: matched by search, labelled, never sent to the API', () {
      expect(customMatches(''), isTrue);
      expect(customMatches('Custom'), isTrue);
      expect(customMatches('jar'), isTrue);
      expect(customMatches('paper'), isFalse);
      const c = SoftwareChoice.custom();
      expect(c.custom, isTrue);
      expect(c.label, 'Custom software');
      expect(c.software, isNull);
      expect(c.latestType, isNull);
      expect(const SoftwareChoice.latest('paper').custom, isFalse);
    });
  });

  group('config options', () {
    test('float step, multiselect arrays and explicit nulls parse', () async {
      final api = FakeAdapter({
        'GET /servers/abc/files/config/server.properties/': (200, fixture('config_multiselect')),
      });
      final opts = await fakeClient(api).getConfig('abc', 'server.properties');
      expect(opts[0].type, ConfigOptionType.float);
      expect((opts[0].min, opts[0].max, opts[0].step), (0.1, 2, 0.1));
      expect(opts[1].type, ConfigOptionType.multiselect);
      expect(opts[1].value, ['bundle', 'trade_rebalance']);
      expect(opts[1].options, hasLength(3));
      expect(opts[2].options, isEmpty);
      expect((opts[2].min, opts[2].max, opts[2].step), (null, null, null));
    });

    test('a multiselect change is sent as an array', () async {
      final api = FakeAdapter({'POST /servers/abc/files/config/server.properties/': (200, ok([]))});
      await fakeClient(api).updateConfig('abc', 'server.properties', {
        'features': ['bundle'],
      });
      expect(api.requests.single.data, {
        'features': ['bundle'],
      });
    });
  });
}
