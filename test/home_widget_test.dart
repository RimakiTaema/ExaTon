import 'package:exaton/core/exaroton/models.dart';
import 'package:exaton/features/widget/home_widget.dart';
import 'package:flutter_test/flutter_test.dart';

Server srv(ServerStatus status, {bool shared = false}) => Server.fromJson({
  'id': 'S1',
  'name': 'Survival',
  'address': 'survival.exaroton.me',
  'motd': '',
  'status': status.code,
  'players': {'max': 20, 'count': 3, 'list': <String>[]},
  'shared': shared,
});

void main() {
  test('widget shows status, players and the right button', () {
    final online = widgetData(accountId: 'acc', server: srv(ServerStatus.online), credits: 12.5);
    expect(online['status'], 'Online - 3/20 players');
    expect(online['action'], 'stop');
    expect(online['credits'], '12.50 credits');
    expect(widgetData(accountId: 'acc', server: srv(ServerStatus.crashed))['action'], 'start');
    expect(widgetData(accountId: 'acc', server: srv(ServerStatus.starting))['action'], '');
    expect(widgetData(accountId: 'acc', server: srv(ServerStatus.offline, shared: true))['action'], '');
    expect(widgetData(accountId: 'acc', server: srv(ServerStatus.offline)).containsKey('credits'), isFalse);
    expect(widgetData(accountId: 'acc')['name'], 'No server');
  });

  test('button links parse, anything else is ignored', () {
    final a = parseWidgetAction(Uri.parse('exaton://start?server=S1&account=acc'))!;
    expect((a.action, a.serverId, a.accountId), ('start', 'S1', 'acc'));
    expect(parseWidgetAction(Uri.parse('exaton://delete?server=S1&account=acc')), isNull);
    expect(parseWidgetAction(Uri.parse('https://start?server=S1&account=acc')), isNull);
    expect(parseWidgetAction(Uri.parse('exaton://stop?server=S1')), isNull);
    expect(parseWidgetAction(null), isNull);
  });
}
