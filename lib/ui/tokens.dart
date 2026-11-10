import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Semantic colour tokens. Widgets read these (or the derived
/// [ColorScheme]); no widget sets its own colours. A custom theme changes
/// tokens, never individual widgets.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.background,
    required this.surface,
    required this.outline,
    required this.outlineStrong,
    required this.primary,
    required this.success,
    required this.warning,
    required this.error,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.errorContainer,
    required this.onErrorContainer,
  });

  final Color background;
  final Color surface;

  /// Decorative edges only: dividers and card borders.
  final Color outline;

  /// Borders a user must find to operate: inputs, outlined buttons,
  /// checkboxes. At least 3:1 against [background] and [surface].
  final Color outlineStrong;
  final Color primary;

  /// Online status and healthy time left. Independent of the accent, so
  /// status stays recognisable on any accent.
  final Color success;
  final Color warning;
  final Color error;
  final Color onSurface;
  final Color onSurfaceMuted;

  /// Pills and banners. Each `on…` reaches 4.5:1 on its container.
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color errorContainer;
  final Color onErrorContainer;

  /// Tokens a theme file must set.
  static const names = [
    'background',
    'surface',
    'outline',
    'primary',
    'warning',
    'error',
    'onSurface',
    'onSurfaceMuted',
  ];

  /// Tokens a theme file may set; derived when missing.
  static const optionalNames = [
    'outlineStrong',
    'success',
    'successContainer',
    'onSuccessContainer',
    'warningContainer',
    'onWarningContainer',
    'errorContainer',
    'onErrorContainer',
  ];

  static final dark = AppTokens.derive(
    background: const Color(0xFF0E1316),
    surface: const Color(0xFF161D22),
    outline: const Color(0xFF2A353C),
    outlineStrong: const Color(0xFF5C6D76),
    primary: const Color(0xFF4FD1A5),
    success: const Color(0xFF4FD1A5),
    warning: const Color(0xFFF5B84B),
    error: const Color(0xFFFF6B6B),
    onSurface: const Color(0xFFE8EEF1),
    onSurfaceMuted: const Color(0xFF9AA9B2),
  );

  static final light = AppTokens.derive(
    background: const Color(0xFFF4F7F8),
    surface: const Color(0xFFFFFFFF),
    outline: const Color(0xFFD3DCE0),
    outlineStrong: const Color(0xFF6F7F87),
    primary: const Color(0xFF0D805D),
    success: const Color(0xFF0D805D),
    warning: const Color(0xFF9A6200),
    error: const Color(0xFFC62828),
    onSurface: const Color(0xFF0E1316),
    onSurfaceMuted: const Color(0xFF4E5C64),
    successContainer: const Color(0xFFD8F1E8),
    onSuccessContainer: const Color(0xFF0A6B4D),
    warningContainer: const Color(0xFFFBEBC9),
    onWarningContainer: const Color(0xFF7A4E00),
    errorContainer: const Color(0xFFFBDADA),
    onErrorContainer: const Color(0xFFA61F1F),
  );

  /// Builds a full set from the required tokens. Missing optional tokens
  /// are derived: dark themes tint containers at 14% over the surface, light
  /// themes use a light solid container with a darkened label, and every
  /// derived colour is nudged until it passes its contrast pair.
  factory AppTokens.derive({
    required Color background,
    required Color surface,
    required Color outline,
    required Color primary,
    required Color warning,
    required Color error,
    required Color onSurface,
    required Color onSurfaceMuted,
    Color? outlineStrong,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? errorContainer,
    Color? onErrorContainer,
  }) {
    final isDark = background.computeLuminance() < 0.5;
    final ok = success ?? (isDark ? const Color(0xFF4FD1A5) : const Color(0xFF0D805D));
    Color container(Color c) => Color.alphaBlend(c.withValues(alpha: isDark ? 0.14 : 0.16), surface);
    Color label(Color c, Color bg) => ensureContrast(isDark ? c : _darken(c, 0.2), bg, 4.5);
    final sc = successContainer ?? container(ok);
    final wc = warningContainer ?? container(warning);
    final ec = errorContainer ?? container(error);
    return AppTokens(
      background: background,
      surface: surface,
      outline: outline,
      outlineStrong: outlineStrong ?? ensureContrast(outline, background, 3, against2: surface),
      primary: primary,
      success: ok,
      warning: warning,
      error: error,
      onSurface: onSurface,
      onSurfaceMuted: onSurfaceMuted,
      successContainer: sc,
      onSuccessContainer: onSuccessContainer ?? label(ok, sc),
      warningContainer: wc,
      onWarningContainer: onWarningContainer ?? label(warning, wc),
      errorContainer: ec,
      onErrorContainer: onErrorContainer ?? label(error, ec),
    );
  }

  bool get isDark => background.computeLuminance() < 0.5;

  /// Colour a foreground needs on top of [primary] (button labels).
  Color get onPrimary =>
      contrastRatio(primary, const Color(0xFF0E1316)) >= 4.5 ? const Color(0xFF0E1316) : const Color(0xFFFFFFFF);

  /// Label on [error] (destructive buttons).
  Color get onError =>
      contrastRatio(error, const Color(0xFF0E1316)) >= 4.5 ? const Color(0xFF0E1316) : const Color(0xFFFFFFFF);

  Color get busy => warning;
  Color get idle => onSurfaceMuted;

  /// Darkens the log panel slightly in dark themes; plain surface in light.
  Color get consoleBackground => isDark ? Color.alphaBlend(const Color(0x40000000), background) : surface;

  /// Dims the page behind a popup.
  Color get scrim => const Color(0x8A000000);

  /// Fill for a selected toggle ("Following", a selected accent).
  Color get selectedFill => Color.alphaBlend(primary.withValues(alpha: isDark ? 0.12 : 0.08), surface);

  /// Label on [selectedFill]: the accent, adjusted until it reaches 4.5:1.
  Color get onSelectedFill => ensureContrast(primary, selectedFill, 4.5);

  Color tone(Tone t) => switch (t) {
    Tone.success => success,
    Tone.warning => warning,
    Tone.error => error,
  };

  Color container(Tone t) => switch (t) {
    Tone.success => successContainer,
    Tone.warning => warningContainer,
    Tone.error => errorContainer,
  };

  Color onContainer(Tone t) => switch (t) {
    Tone.success => onSuccessContainer,
    Tone.warning => onWarningContainer,
    Tone.error => onErrorContainer,
  };

  /// Raises text and border contrast for the High contrast option.
  AppTokens highContrast() {
    final d = isDark;
    return copyWith(
      onSurface: d ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
      onSurfaceMuted: d ? const Color(0xFFD0DBE1) : const Color(0xFF26323A),
      outline: d ? const Color(0xFF7D8F99) : const Color(0xFF5A6A73),
      outlineStrong: d ? const Color(0xFFA9BAC3) : const Color(0xFF3A474E),
      onSuccessContainer: ensureContrast(onSuccessContainer, successContainer, 7),
      onWarningContainer: ensureContrast(onWarningContainer, warningContainer, 7),
      onErrorContainer: ensureContrast(onErrorContainer, errorContainer, 7),
    );
  }

  @override
  AppTokens copyWith({
    Color? background,
    Color? surface,
    Color? outline,
    Color? outlineStrong,
    Color? primary,
    Color? success,
    Color? warning,
    Color? error,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? errorContainer,
    Color? onErrorContainer,
  }) => AppTokens(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    outline: outline ?? this.outline,
    outlineStrong: outlineStrong ?? this.outlineStrong,
    primary: primary ?? this.primary,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    onSurface: onSurface ?? this.onSurface,
    onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
    successContainer: successContainer ?? this.successContainer,
    onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    warningContainer: warningContainer ?? this.warningContainer,
    onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    errorContainer: errorContainer ?? this.errorContainer,
    onErrorContainer: onErrorContainer ?? this.onErrorContainer,
  );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      outline: l(outline, other.outline),
      outlineStrong: l(outlineStrong, other.outlineStrong),
      primary: l(primary, other.primary),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      error: l(error, other.error),
      onSurface: l(onSurface, other.onSurface),
      onSurfaceMuted: l(onSurfaceMuted, other.onSurfaceMuted),
      successContainer: l(successContainer, other.successContainer),
      onSuccessContainer: l(onSuccessContainer, other.onSuccessContainer),
      warningContainer: l(warningContainer, other.warningContainer),
      onWarningContainer: l(onWarningContainer, other.onWarningContainer),
      errorContainer: l(errorContainer, other.errorContainer),
      onErrorContainer: l(onErrorContainer, other.onErrorContainer),
    );
  }

  Map<String, Color> toMap() => {
    'background': background,
    'surface': surface,
    'outline': outline,
    'outlineStrong': outlineStrong,
    'primary': primary,
    'success': success,
    'warning': warning,
    'error': error,
    'onSurface': onSurface,
    'onSurfaceMuted': onSurfaceMuted,
    'successContainer': successContainer,
    'onSuccessContainer': onSuccessContainer,
    'warningContainer': warningContainer,
    'onWarningContainer': onWarningContainer,
    'errorContainer': errorContainer,
    'onErrorContainer': onErrorContainer,
  };

  String toJson() => const JsonEncoder.withIndent('  ').convert({
    'name': 'ExaTon theme',
    'version': 2,
    'tokens': {for (final e in toMap().entries) e.key: hex(e.value)},
  });

  /// Parses a theme file. Version 1 files (the eight required tokens) still
  /// load; the rest are derived. Throws [ThemeImportException] naming the
  /// problem, including the first pair below its required contrast.
  static AppTokens fromJson(String source) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      throw const ThemeImportException('The file is not valid JSON.');
    }
    final raw = root is Map && root['tokens'] is Map ? root['tokens'] as Map : root;
    if (raw is! Map) throw const ThemeImportException('The file has no tokens.');
    final colors = <String, Color>{};
    for (final name in names) {
      final v = raw[name];
      final c = v is String ? parseHex(v) : null;
      if (c == null) throw ThemeImportException('Token "$name" is missing or is not a #RRGGBB colour.');
      colors[name] = c;
    }
    for (final name in optionalNames) {
      final v = raw[name];
      if (v == null) continue;
      final c = v is String ? parseHex(v) : null;
      if (c == null) throw ThemeImportException('Token "$name" is not a #RRGGBB colour.');
      colors[name] = c;
    }
    final t = AppTokens.derive(
      background: colors['background']!,
      surface: colors['surface']!,
      outline: colors['outline']!,
      primary: colors['primary']!,
      warning: colors['warning']!,
      error: colors['error']!,
      onSurface: colors['onSurface']!,
      onSurfaceMuted: colors['onSurfaceMuted']!,
      outlineStrong: colors['outlineStrong'],
      success: colors['success'],
      successContainer: colors['successContainer'],
      onSuccessContainer: colors['onSuccessContainer'],
      warningContainer: colors['warningContainer'],
      onWarningContainer: colors['onWarningContainer'],
      errorContainer: colors['errorContainer'],
      onErrorContainer: colors['onErrorContainer'],
    );
    final bad = t.failingContrastPair();
    if (bad != null) {
      throw ThemeImportException(
        '${bad.fg} on ${bad.bg} has contrast ${bad.ratio.toStringAsFixed(2)}:1, '
        'below the required ${bad.required.toStringAsFixed(1)}:1.',
      );
    }
    return t;
  }

  /// Every pair that must reach a contrast ratio: text at 4.5:1, control
  /// borders at 3:1.
  static const contrastPairs = <(String, String, double)>[
    ('onSurface', 'background', 4.5),
    ('onSurface', 'surface', 4.5),
    ('onSurfaceMuted', 'background', 4.5),
    ('onSurfaceMuted', 'surface', 4.5),
    ('success', 'surface', 4.5),
    ('warning', 'surface', 4.5),
    ('error', 'surface', 4.5),
    ('success', 'background', 4.5),
    ('warning', 'background', 4.5),
    ('error', 'background', 4.5),
    ('onSuccessContainer', 'successContainer', 4.5),
    ('onWarningContainer', 'warningContainer', 4.5),
    ('onErrorContainer', 'errorContainer', 4.5),
    ('outlineStrong', 'background', 3),
    ('outlineStrong', 'surface', 3),
  ];

  /// First pair below its required ratio, or null.
  ({String fg, String bg, double ratio, double required})? failingContrastPair() {
    final m = toMap();
    for (final (fg, bg, need) in contrastPairs) {
      final r = contrastRatio(m[fg]!, m[bg]!);
      if (r < need) return (fg: fg, bg: bg, ratio: r, required: need);
    }
    return null;
  }
}

class ThemeImportException implements Exception {
  const ThemeImportException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// WCAG 2 contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Moves [fg] away from [bg] (towards white on dark, black on light) until
/// it reaches [ratio] against [bg] and, if given, [against2].
Color ensureContrast(Color fg, Color bg, double ratio, {Color? against2}) {
  bool passes(Color c) => contrastRatio(c, bg) >= ratio && (against2 == null || contrastRatio(c, against2) >= ratio);
  if (passes(fg)) return fg;
  final target = bg.computeLuminance() < 0.5 ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  for (var t = 0.05; t <= 1.0; t += 0.05) {
    final c = Color.lerp(fg, target, t)!;
    if (passes(c)) return c;
  }
  return target;
}

Color _darken(Color c, double amount) => Color.lerp(c, const Color(0xFF000000), amount)!;

String hex(Color c) {
  final v = c.toARGB32() & 0xFFFFFF;
  return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color? parseHex(String s) {
  final m = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(s.trim());
  if (m == null) return null;
  return Color(0xFF000000 | int.parse(m.group(1)!, radix: 16));
}

/// Semantic tone for status text, pills and banners.
enum Tone { success, warning, error }

/// Accent choices, shown with names so colour is not the only cue.
enum Accent {
  mint('Mint', Color(0xFF4FD1A5), Color(0xFF0D805D)),
  blue('Blue', Color(0xFF5AA9FF), Color(0xFF1F66C2)),
  purple('Purple', Color(0xFFA98BFF), Color(0xFF6B48D6)),
  pink('Pink', Color(0xFFFF85C8), Color(0xFFBF2F82)),
  orange('Orange', Color(0xFFFFA351), Color(0xFFB4570A)),
  red('Red', Color(0xFFFF6B6B), Color(0xFFC62828));

  const Accent(this.label, this.onDark, this.onLight);
  final String label;
  final Color onDark;
  final Color onLight;
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>() ?? AppTokens.dark;
}
