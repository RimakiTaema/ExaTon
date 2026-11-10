import 'package:flutter/material.dart';

import 'app_icons.dart';
import 'tokens.dart';

enum ThemeModeSetting { light, dark, system }

enum ContrastSetting { standard, high }

/// Settings that pick a theme.
@immutable
class ThemeSettings {
  const ThemeSettings({
    this.mode = ThemeModeSetting.system,
    this.accent = Accent.mint,
    this.contrast = ContrastSetting.standard,
    this.customDark,
  });

  final ThemeModeSetting mode;
  final Accent accent;
  final ContrastSetting contrast;

  /// An imported theme. Replaces the dark tokens; the accent is ignored.
  final AppTokens? customDark;

  ThemeSettings copyWith({
    ThemeModeSetting? mode,
    Accent? accent,
    ContrastSetting? contrast,
    AppTokens? customDark,
    bool clearCustom = false,
  }) => ThemeSettings(
    mode: mode ?? this.mode,
    accent: accent ?? this.accent,
    contrast: contrast ?? this.contrast,
    customDark: clearCustom ? null : (customDark ?? this.customDark),
  );

  ThemeMode get themeMode => switch (mode) {
    ThemeModeSetting.light => ThemeMode.light,
    ThemeModeSetting.dark => ThemeMode.dark,
    ThemeModeSetting.system => ThemeMode.system,
  };

  AppTokens tokensFor(Brightness b) {
    var t = b == Brightness.dark
        ? (customDark ?? AppTokens.dark.copyWith(primary: accent.onDark))
        : AppTokens.light.copyWith(primary: accent.onLight);
    if (contrast == ContrastSetting.high) t = t.highContrast();
    return t;
  }

  @override
  bool operator ==(Object other) =>
      other is ThemeSettings &&
      other.mode == mode &&
      other.accent == accent &&
      other.contrast == contrast &&
      other.customDark == customDark;

  @override
  int get hashCode => Object.hash(mode, accent, contrast, customDark);
}

/// Bundled fonts (see pubspec.yaml).
const uiFont = 'Inter';
const monoFont = 'JetBrains Mono';

/// Builds Material 3 theme data from tokens. Everything visual flows from
/// here.
ThemeData buildTheme(AppTokens t, Brightness brightness, {bool highContrast = false}) {
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.primary,
    onPrimary: t.onPrimary,
    secondary: t.primary,
    onSecondary: t.onPrimary,
    error: t.error,
    onError: t.onError,
    surface: t.surface,
    onSurface: t.onSurface,
    onSurfaceVariant: t.onSurfaceMuted,
    surfaceContainerLowest: t.background,
    surfaceContainerLow: t.background,
    surfaceContainer: t.surface,
    surfaceContainerHigh: Color.alphaBlend(t.onSurface.withValues(alpha: 0.04), t.surface),
    surfaceContainerHighest: Color.alphaBlend(t.onSurface.withValues(alpha: 0.08), t.surface),
    outline: t.outlineStrong,
    outlineVariant: t.outline,
    tertiary: t.warning,
    onTertiary: t.background,
    errorContainer: t.errorContainer,
    onErrorContainer: t.onErrorContainer,
  );

  final focusWidth = highContrast ? 3.0 : 2.0;
  final radius = BorderRadius.circular(14);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness, fontFamily: uiFont);
  final text = base.textTheme.apply(bodyColor: t.onSurface, displayColor: t.onSurface);

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: c, width: w),
  );

  const minTarget = Size(44, 44);

  return base.copyWith(
    scaffoldBackgroundColor: t.background,
    // Back and close buttons use the app's icon set too.
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (_) => const Icon(AppIcons.back),
      closeButtonIconBuilder: (_) => const Icon(AppIcons.close),
    ),
    // One page transition everywhere: the new page fades forward over the
    // old one (Material 3 motion), on phone and desktop alike.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    canvasColor: t.background,
    dividerColor: t.outline,
    extensions: [t],
    textTheme: text.copyWith(
      headlineLarge: text.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodySmall: text.bodySmall?.copyWith(color: t.onSurfaceMuted),
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: t.background,
      foregroundColor: t.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: t.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: t.outline),
      ),
    ),
    dividerTheme: DividerThemeData(color: t.outline, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surface,
      hintStyle: TextStyle(fontFamily: uiFont, color: t.onSurfaceMuted),
      prefixIconColor: t.onSurfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(t.outlineStrong),
      enabledBorder: border(t.outlineStrong),
      focusedBorder: border(t.primary, focusWidth),
      errorBorder: border(t.error),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: minTarget,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontFamily: uiFont, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: minTarget,
        foregroundColor: t.onSurface,
        side: BorderSide(color: t.outlineStrong),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontFamily: uiFont, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: minTarget, foregroundColor: t.primary),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: minTarget, foregroundColor: t.onSurface),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: t.background,
      selectedColor: t.onSurface,
      labelStyle: TextStyle(fontFamily: uiFont, color: t.onSurface, fontWeight: FontWeight.w600),
      secondaryLabelStyle: TextStyle(fontFamily: uiFont, color: t.background, fontWeight: FontWeight.w700),
      side: BorderSide(color: t.outlineStrong),
      shape: const StadiumBorder(),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        minimumSize: minTarget,
        backgroundColor: t.surface,
        foregroundColor: t.onSurfaceMuted,
        selectedBackgroundColor: t.onSurface,
        selectedForegroundColor: t.background,
        side: BorderSide(color: t.outlineStrong),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.background,
      indicatorColor: const Color(0x00000000),
      surfaceTintColor: const Color(0x00000000),
      height: 72,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? t.primary : t.onSurfaceMuted, size: 28),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: uiFont,
          color: s.contains(WidgetState.selected) ? t.primary : t.onSurfaceMuted,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: t.background,
      indicatorColor: t.surface,
      selectedIconTheme: IconThemeData(color: t.primary),
      unselectedIconTheme: IconThemeData(color: t.onSurfaceMuted),
      selectedLabelTextStyle: TextStyle(fontFamily: uiFont, color: t.primary, fontWeight: FontWeight.w700),
      unselectedLabelTextStyle: TextStyle(fontFamily: uiFont, color: t.onSurfaceMuted),
      labelType: NavigationRailLabelType.all,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: t.onSurface,
      unselectedLabelColor: t.onSurfaceMuted,
      indicatorColor: t.primary,
      dividerColor: t.outline,
      indicatorSize: TabBarIndicatorSize.tab,
      tabAlignment: TabAlignment.start,
      labelStyle: const TextStyle(fontFamily: uiFont, fontWeight: FontWeight.w700, fontSize: 15),
      unselectedLabelStyle: const TextStyle(fontFamily: uiFont, fontWeight: FontWeight.w600, fontSize: 15),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.surface,
      contentTextStyle: TextStyle(fontFamily: uiFont, color: t.onSurface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: t.outline),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: t.outline),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: t.outline),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: t.surface),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: t.primary, linearTrackColor: t.outline),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.onPrimary : t.onSurfaceMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.primary : t.surface),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.primary : t.outlineStrong,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: t.outlineStrong, width: 2),
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? t.primary : null),
      checkColor: WidgetStatePropertyAll(t.onPrimary),
    ),
    // Thicker focus ring in High contrast, on every focusable control.
    focusColor: t.primary.withValues(alpha: highContrast ? 0.4 : 0.24),
  );
}
