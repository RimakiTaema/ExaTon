import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/database.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../credits/estimate.dart';

const defaultQuickCommands = ['list', 'save-all', 'whitelist list'];

@immutable
class AppSettings {
  const AppSettings({
    this.theme = const ThemeSettings(),
    this.estimateMethod = EstimateMethod.runningServers,
    this.alertsEnabled = true,
    this.alertThresholdDays = 5,
    this.creditFloor,
    this.quickCommands = defaultQuickCommands,
    this.mutedPools = const {},
  });

  final ThemeSettings theme;
  final EstimateMethod estimateMethod;
  final bool alertsEnabled;
  final int alertThresholdDays;
  final double? creditFloor;
  final List<String> quickCommands;

  /// Pools whose low-credit alerts are off. The global switch and the
  /// threshold stay in [alertsEnabled] and [alertThresholdDays].
  final Set<String> mutedPools;

  bool alertsOnFor(String poolId) => alertsEnabled && !mutedPools.contains(poolId);

  AppSettings copyWith({
    ThemeSettings? theme,
    EstimateMethod? estimateMethod,
    bool? alertsEnabled,
    int? alertThresholdDays,
    double? creditFloor,
    bool clearCreditFloor = false,
    List<String>? quickCommands,
    Set<String>? mutedPools,
  }) => AppSettings(
    theme: theme ?? this.theme,
    estimateMethod: estimateMethod ?? this.estimateMethod,
    alertsEnabled: alertsEnabled ?? this.alertsEnabled,
    alertThresholdDays: alertThresholdDays ?? this.alertThresholdDays,
    creditFloor: clearCreditFloor ? null : (creditFloor ?? this.creditFloor),
    quickCommands: quickCommands ?? this.quickCommands,
    mutedPools: mutedPools ?? this.mutedPools,
  );

  Map<String, dynamic> toJson() => {
    'mode': theme.mode.name,
    'accent': theme.accent.name,
    'contrast': theme.contrast.name,
    if (theme.customDark != null) 'customTheme': theme.customDark!.toJson(),
    'estimateMethod': estimateMethod.name,
    'alertsEnabled': alertsEnabled,
    'alertThresholdDays': alertThresholdDays,
    'creditFloor': creditFloor,
    'quickCommands': quickCommands,
    'mutedPools': mutedPools.toList(),
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    T pick<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.firstWhere((v) => v.name == name, orElse: () => fallback);
    AppTokens? custom;
    if (j['customTheme'] is String) {
      try {
        custom = AppTokens.fromJson(j['customTheme'] as String);
      } catch (_) {}
    }
    return AppSettings(
      theme: ThemeSettings(
        mode: pick(ThemeModeSetting.values, j['mode'], ThemeModeSetting.system),
        accent: pick(Accent.values, j['accent'], Accent.mint),
        contrast: pick(ContrastSetting.values, j['contrast'], ContrastSetting.standard),
        customDark: custom,
      ),
      estimateMethod: pick(EstimateMethod.values, j['estimateMethod'], EstimateMethod.runningServers),
      alertsEnabled: j['alertsEnabled'] != false,
      alertThresholdDays: (j['alertThresholdDays'] as num?)?.toInt().clamp(1, 60) ?? 5,
      creditFloor: (j['creditFloor'] as num?)?.toDouble(),
      quickCommands: j['quickCommands'] is List
          ? (j['quickCommands'] as List).whereType<String>().toList()
          : defaultQuickCommands,
      mutedPools: j['mutedPools'] is List ? (j['mutedPools'] as List).whereType<String>().toSet() : const {},
    );
  }

  static Future<AppSettings> load(AppDatabase db) async {
    final j = await db.readJson('settings');
    return j == null ? const AppSettings() : AppSettings.fromJson(j);
  }
}

/// Overridden in main with the open database.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('databaseProvider'));

/// Overridden in main with settings read before the first frame, so the
/// theme does not flash.
final initialSettingsProvider = Provider<AppSettings>((ref) => const AppSettings());

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    state = change(state);
    await ref.read(databaseProvider).writeJson('settings', state.toJson());
  }

  Future<void> setTheme(ThemeSettings theme) => update((s) => s.copyWith(theme: theme));
}
