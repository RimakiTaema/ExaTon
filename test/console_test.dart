import 'package:exaton/core/console/ansi.dart';
import 'package:exaton/core/console/ring_buffer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAnsi', () {
    test('plain text is one unstyled span', () {
      expect(parseAnsi('[10:42:15 INFO]: Steve joined the game'), [
        const AnsiSpan('[10:42:15 INFO]: Steve joined the game'),
      ]);
    });

    test('colour codes become styled spans', () {
      final spans = parseAnsi('\x1B[33m[WARN]\x1B[0m Can\'t keep up');
      expect(spans, [const AnsiSpan('[WARN]', color: AnsiColor.yellow), const AnsiSpan(' Can\'t keep up')]);
    });

    test('bright colours, bold and combined params', () {
      final spans = parseAnsi('\x1B[1;91mERR\x1B[22m!');
      expect(spans, [
        const AnsiSpan('ERR', color: AnsiColor.brightRed, bold: true),
        const AnsiSpan('!', color: AnsiColor.brightRed),
      ]);
    });

    test('256-colour arguments are not read as codes', () {
      // 38;5;1 is red; the "1" must not turn on bold.
      final spans = parseAnsi('\x1B[38;5;1mx');
      expect(spans, [const AnsiSpan('x', color: AnsiColor.red)]);
      // Truecolour is skipped without leaking its args.
      expect(parseAnsi('\x1B[38;2;1;2;3my'), [const AnsiSpan('y')]);
    });

    test('other escapes and control characters are stripped', () {
      expect(parseAnsi('a\x1B[2Kb\x1B]0;title\x07c\rd\x00e'), [const AnsiSpan('abcde')]);
      expect(stripAnsi('\x1B[32m> list\x1B[m\r'), '> list');
    });

    test('adjacent spans with the same style merge', () {
      expect(parseAnsi('\x1B[32mab\x1B[32mcd'), [const AnsiSpan('abcd', color: AnsiColor.green)]);
    });

    test('reset with empty params', () {
      expect(parseAnsi('\x1B[31mr\x1B[mn'), [const AnsiSpan('r', color: AnsiColor.red), const AnsiSpan('n')]);
    });
  });

  group('RingBuffer', () {
    test('keeps the newest items in order', () {
      final b = RingBuffer<int>(3)..addAll([1, 2, 3, 4, 5]);
      expect(b.toList(), [3, 4, 5]);
      expect(b.length, 3);
      expect(b[0], 3);
      expect(b.totalAdded, 5);
    });

    test('sequence numbers stay stable across evictions', () {
      final b = RingBuffer<String>(2)..addAll(['a', 'b']);
      expect(b.sequenceOf(1), 1);
      b.add('c');
      expect(b[1], 'c');
      expect(b.sequenceOf(1), 2);
      expect(b.sequenceOf(0), 1);
    });

    test('clear empties the buffer', () {
      final b = RingBuffer<int>(5)..addAll([1, 2]);
      b.clear();
      expect(b.isEmpty, isTrue);
      b.add(9);
      expect(b.toList(), [9]);
    });

    test('holds 5,000 lines', () {
      final b = RingBuffer<int>(5000)..addAll(List.generate(12000, (i) => i));
      expect(b.length, 5000);
      expect(b[0], 7000);
      expect(b[4999], 11999);
      expect(() => b[5000], throwsRangeError);
    });
  });
}
