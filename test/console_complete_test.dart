import 'package:exaton/core/console/complete.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const players = ['Alex', 'alice_99', 'Steve'];

  test('completes the last word against online players', () {
    expect(playerCompletions('tp al', players), ['Alex', 'alice_99']);
    expect(playerCompletions('tp ST', players), ['Steve']);
    expect(playerCompletions('tp Steve', players), isEmpty, reason: 'already complete');
    expect(playerCompletions('tp ', players), isEmpty);
    expect(playerCompletions('', players), isEmpty);
    expect(playerCompletions('a', players), ['Alex', 'alice_99']);
  });

  test('replaces only the last word', () {
    expect(completeWith('tp al', 'Alex'), 'tp Alex ');
    expect(completeWith('al', 'alice_99'), 'alice_99 ');
    expect(lastWord('give Steve dia'), 'dia');
  });
}
