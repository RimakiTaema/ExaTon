import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/shell.dart';
import 'core/storage/database.dart';
import 'features/credits/alerts.dart';
import 'features/settings/settings.dart';
import 'features/widget/home_widget.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bundled fonts: Inter and JetBrains Mono (SIL Open Font License) and
  // Phosphor icons (MIT). List them on the licences page.
  LicenseRegistry.addLicense(() async* {
    for (final (pkg, file) in const [
      ('Inter', 'Inter-LICENSE.txt'),
      ('JetBrains Mono', 'JetBrainsMono-OFL.txt'),
      ('Phosphor Icons', 'Phosphor-LICENSE.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([pkg], await rootBundle.loadString('assets/fonts/$file'));
    }
  });
  final db = AppDatabase.open();
  final settings = await AppSettings.load(db);
  await CreditAlerts.instance.init();
  try {
    await registerBackgroundCheck(settings);
  } catch (_) {}
  await registerWidgetActions();
  runApp(
    ProviderScope(
      // Errors are shown with a retry button; no silent automatic retries.
      retry: (_, _) => null,
      overrides: [databaseProvider.overrideWithValue(db), initialSettingsProvider.overrideWithValue(settings)],
      child: const ExaTonApp(),
    ),
  );
}

class ExaTonApp extends ConsumerWidget {
  const ExaTonApp({super.key, this.home});
  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider.select((s) => s.theme));
    final high = theme.contrast == ContrastSetting.high;
    return MaterialApp(
      title: 'ExaTon',
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      theme: buildTheme(theme.tokensFor(Brightness.light), Brightness.light, highContrast: high),
      darkTheme: buildTheme(theme.tokensFor(Brightness.dark), Brightness.dark, highContrast: high),
      home: home ?? const AppShell(),
    );
  }
}
