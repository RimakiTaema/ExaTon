import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../accounts/accounts.dart';
import '../credits/credits.dart';
import '../servers/servers.dart';
import 'home_widget.dart';

/// What the home-screen widget should show: the server open in the app,
/// else the first one the account owns.
final homeWidgetDataProvider = Provider<Map<String, String>?>((ref) {
  final account = ref.watch(activeAccountProvider);
  final list = ref.watch(serversProvider).value;
  if (account == null || list == null) return null;
  final selected = ref.watch(selectedServerProvider);
  final server =
      list.where((s) => s.id == selected).firstOrNull ?? list.where((s) => !s.shared).firstOrNull ?? list.firstOrNull;
  final credits = ref.watch(creditsOverviewProvider).value?.accountSummary.credits;
  return widgetData(accountId: account.id, server: server, credits: credits);
});
