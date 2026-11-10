import 'package:exaton/ui/theme.dart';
import 'package:exaton/ui/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tokens', () {
    test('dark defaults match the spec', () {
      expect(hex(AppTokens.dark.background), '#0E1316');
      expect(hex(AppTokens.dark.surface), '#161D22');
      expect(hex(AppTokens.dark.outline), '#2A353C');
      expect(hex(AppTokens.dark.primary), '#4FD1A5');
      expect(hex(AppTokens.dark.warning), '#F5B84B');
      expect(hex(AppTokens.dark.error), '#FF6B6B');
      expect(hex(AppTokens.dark.onSurface), '#E8EEF1');
      expect(hex(AppTokens.dark.onSurfaceMuted), '#9AA9B2');
    });

    // UX review P0 #3 and #4: every pair in the theme section, in both
    // themes, with every accent and in High contrast.
    for (final contrast in ContrastSetting.values) {
      for (final accent in Accent.values) {
        for (final b in Brightness.values) {
          test('all pairs pass: ${b.name}, ${accent.label}, ${contrast.name}', () {
            final t = ThemeSettings(accent: accent, contrast: contrast).tokensFor(b);
            final bad = t.failingContrastPair();
            expect(bad, isNull, reason: bad == null ? null : '${bad.fg} on ${bad.bg}: ${bad.ratio.toStringAsFixed(2)}');
            expect(contrastRatio(t.onSelectedFill, t.selectedFill), greaterThanOrEqualTo(4.5));
            expect(contrastRatio(t.onError, t.error), greaterThanOrEqualTo(4.5));
          });
        }
      }
    }

    test('light containers use the spec values', () {
      final t = AppTokens.light;
      expect(hex(t.warningContainer), '#FBEBC9');
      expect(hex(t.onWarningContainer), '#7A4E00');
      expect(hex(t.successContainer), '#D8F1E8');
      expect(hex(t.errorContainer), '#FBDADA');
      expect(hex(t.outlineStrong), '#6F7F87');
      expect(hex(AppTokens.dark.outlineStrong), '#5C6D76');
    });

    test('controls use outlineStrong, dividers keep outline', () {
      final t = AppTokens.dark;
      final theme = buildTheme(t, Brightness.dark);
      final enabled = theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
      expect(enabled.borderSide.color, t.outlineStrong);
      expect(theme.dividerTheme.color, t.outline);
      expect(theme.checkboxTheme.side!.color, t.outlineStrong);
    });

    test('ensureContrast moves a colour until it passes', () {
      const bg = Color(0xFF0E1316);
      final c = ensureContrast(const Color(0xFF20282E), bg, 3);
      expect(contrastRatio(c, bg), greaterThanOrEqualTo(3));
    });

    // Spec: each accent needs a check against both backgrounds.
    for (final a in Accent.values) {
      test('${a.label} accent: button label 4.5:1 and 3:1 against its background', () {
        for (final (tokens, accent) in [(AppTokens.dark, a.onDark), (AppTokens.light, a.onLight)]) {
          final t = tokens.copyWith(primary: accent);
          expect(
            contrastRatio(t.onPrimary, t.primary),
            greaterThanOrEqualTo(4.5),
            reason: '${a.label} label on ${hex(accent)}',
          );
          expect(
            contrastRatio(t.primary, t.background),
            greaterThanOrEqualTo(3.0),
            reason: '${a.label} ${hex(accent)} on ${hex(t.background)}',
          );
        }
      });
    }
  });

  group('theme import and export', () {
    test('round trip', () {
      final custom = AppTokens.dark.copyWith(primary: const Color(0xFF5AA9FF));
      final back = AppTokens.fromJson(custom.toJson());
      expect(back.toMap().map((k, v) => MapEntry(k, hex(v))), custom.toMap().map((k, v) => MapEntry(k, hex(v))));
    });

    test('rejects a low-contrast pair and names it', () {
      final bad = AppTokens.dark.copyWith(onSurfaceMuted: const Color(0xFF3A444A)).toJson();
      expect(
        () => AppTokens.fromJson(bad),
        throwsA(
          isA<ThemeImportException>().having((e) => e.message, 'message', contains('onSurfaceMuted on background')),
        ),
      );
    });

    test('rejects missing tokens and bad JSON', () {
      expect(
        () => AppTokens.fromJson('{"tokens": {"background": "#000000"}}'),
        throwsA(isA<ThemeImportException>().having((e) => e.message, 'message', contains('surface'))),
      );
      expect(() => AppTokens.fromJson('not json'), throwsA(isA<ThemeImportException>()));
    });

    test('version 1 files (eight tokens) still import, the rest derived', () {
      const v1 =
          '{"tokens": {"background": "#0E1316", "surface": "#161D22", "outline": "#2A353C", '
          '"primary": "#4FD1A5", "warning": "#F5B84B", "error": "#FF6B6B", "onSurface": "#E8EEF1", '
          '"onSurfaceMuted": "#9AA9B2"}}';
      final t = AppTokens.fromJson(v1);
      expect(t.failingContrastPair(), isNull);
      expect(contrastRatio(t.outlineStrong, t.background), greaterThanOrEqualTo(3));
    });

    test('rejects a control border under 3:1', () {
      final bad = AppTokens.dark.copyWith(outlineStrong: const Color(0xFF2A353C)).toJson();
      expect(
        () => AppTokens.fromJson(bad),
        throwsA(isA<ThemeImportException>().having((e) => e.message, 'message', contains('outlineStrong'))),
      );
    });

    test('accepts a bare token map', () {
      final m = {for (final e in AppTokens.dark.toMap().entries) e.key: hex(e.value)};
      expect(
        AppTokens.fromJson(m.toString().replaceAllMapped(RegExp(r'(\w+): (#\w+)'), (x) => '"${x[1]}": "${x[2]}"')),
        isA<AppTokens>(),
      );
    });
  });

  group('settings', () {
    test('accent applies to primary; custom theme replaces dark tokens', () {
      const s = ThemeSettings(accent: Accent.purple);
      expect(s.tokensFor(Brightness.dark).primary, Accent.purple.onDark);
      expect(s.tokensFor(Brightness.light).primary, Accent.purple.onLight);
      final custom = AppTokens.dark.copyWith(primary: const Color(0xFF123456));
      expect(s.copyWith(customDark: custom).tokensFor(Brightness.dark).primary, const Color(0xFF123456));
    });

    test('theme data is built from tokens only', () {
      final t = AppTokens.dark;
      final data = buildTheme(t, Brightness.dark);
      expect(data.scaffoldBackgroundColor, t.background);
      expect(data.colorScheme.primary, t.primary);
      expect(data.colorScheme.surface, t.surface);
      expect(data.extension<AppTokens>(), t);
    });
  });
}
