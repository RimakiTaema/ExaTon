/// Player names that complete the last word of [input], case-insensitive.
/// Empty when the last word is empty (the input ends with a space).
List<String> playerCompletions(String input, List<String> players) {
  final word = lastWord(input);
  if (word.isEmpty) return const [];
  final w = word.toLowerCase();
  return [
    for (final p in players)
      if (p.toLowerCase().startsWith(w) && p.length > word.length) p,
  ];
}

/// The text after the last space.
String lastWord(String input) {
  final i = input.lastIndexOf(' ');
  return i < 0 ? input : input.substring(i + 1);
}

/// [input] with its last word replaced by [name] and a trailing space.
String completeWith(String input, String name) {
  final i = input.lastIndexOf(' ');
  return '${i < 0 ? '' : input.substring(0, i + 1)}$name ';
}
