// Parses console lines with ANSI SGR codes into styled spans and strips
// every other control sequence. Pure Dart; the UI maps [AnsiColor] to theme
// colors so no widget hard-codes a color.
library;

enum AnsiColor {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
  brightBlack,
  brightRed,
  brightGreen,
  brightYellow,
  brightBlue,
  brightMagenta,
  brightCyan,
  brightWhite,
}

class AnsiSpan {
  const AnsiSpan(this.text, {this.color, this.bold = false, this.italic = false, this.underline = false});
  final String text;
  final AnsiColor? color;
  final bool bold;
  final bool italic;
  final bool underline;

  @override
  bool operator ==(Object other) =>
      other is AnsiSpan &&
      other.text == text &&
      other.color == color &&
      other.bold == bold &&
      other.italic == italic &&
      other.underline == underline;

  @override
  int get hashCode => Object.hash(text, color, bold, italic, underline);

  @override
  String toString() => 'AnsiSpan(${[text, if (color != null) color!.name, if (bold) 'bold'].join(', ')})';
}

class _Style {
  AnsiColor? color;
  bool bold = false;
  bool italic = false;
  bool underline = false;

  void reset() {
    color = null;
    bold = false;
    italic = false;
    underline = false;
  }
}

// CSI sequences, OSC sequences (ending in BEL or ST) and lone two-char escapes.
final _escape = RegExp(r'\x1B\[([0-9;?]*)([@-~])|\x1B\][^\x07\x1B]*(?:\x07|\x1B\\)|\x1B[@-Z\\-_]');
// C0 control characters except tab.
final _controls = RegExp(r'[\x00-\x08\x0B-\x1F\x7F]');

/// Splits [line] into styled spans.
List<AnsiSpan> parseAnsi(String line) {
  final spans = <AnsiSpan>[];
  final style = _Style();
  var last = 0;

  void emit(String raw) {
    final text = raw.replaceAll(_controls, '');
    if (text.isEmpty) return;
    final prev = spans.isEmpty ? null : spans.last;
    if (prev != null &&
        prev.color == style.color &&
        prev.bold == style.bold &&
        prev.italic == style.italic &&
        prev.underline == style.underline) {
      spans[spans.length - 1] = AnsiSpan(
        prev.text + text,
        color: prev.color,
        bold: prev.bold,
        italic: prev.italic,
        underline: prev.underline,
      );
    } else {
      spans.add(AnsiSpan(text, color: style.color, bold: style.bold, italic: style.italic, underline: style.underline));
    }
  }

  for (final m in _escape.allMatches(line)) {
    emit(line.substring(last, m.start));
    last = m.end;
    if (m.group(2) == 'm') _applySgr(m.group(1) ?? '', style);
  }
  emit(line.substring(last));
  return spans;
}

/// Plain text of [line] with every escape removed. Used for search and copy.
String stripAnsi(String line) => line.replaceAll(_escape, '').replaceAll(_controls, '');

void _applySgr(String params, _Style s) {
  final codes = params.isEmpty ? [0] : params.split(';').map((p) => int.tryParse(p) ?? 0).toList();
  for (var i = 0; i < codes.length; i++) {
    final c = codes[i];
    switch (c) {
      case 0:
        s.reset();
      case 1:
        s.bold = true;
      case 3:
        s.italic = true;
      case 4:
        s.underline = true;
      case 22:
        s.bold = false;
      case 23:
        s.italic = false;
      case 24:
        s.underline = false;
      case >= 30 && <= 37:
        s.color = AnsiColor.values[c - 30];
      case 39:
        s.color = null;
      case >= 90 && <= 97:
        s.color = AnsiColor.values[c - 90 + 8];
      case 38:
        // 256-colour (38;5;n) or truecolour (38;2;r;g;b): map the 16 basic
        // indexes, skip the rest so arguments are not read as codes.
        if (i + 1 < codes.length && codes[i + 1] == 5 && i + 2 < codes.length) {
          final n = codes[i + 2];
          if (n < 16) s.color = AnsiColor.values[n];
          i += 2;
        } else if (i + 1 < codes.length && codes[i + 1] == 2) {
          i += 4;
        }
      case 48:
        if (i + 1 < codes.length && codes[i + 1] == 5) {
          i += 2;
        } else if (i + 1 < codes.length && codes[i + 1] == 2) {
          i += 4;
        }
      default:
        break; // Backgrounds and other attributes are ignored.
    }
  }
}
