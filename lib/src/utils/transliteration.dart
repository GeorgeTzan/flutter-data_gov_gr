/// A utility class for transliterating Greek characters to Latin characters.
class Transliteration {
  static const Map<String, String> _map = {
    'Α': 'A',
    'Β': 'V',
    'Γ': 'G',
    'Δ': 'D',
    'Ε': 'E',
    'Ζ': 'Z',
    'Η': 'I',
    'Θ': 'Th',
    'Ι': 'I',
    'Κ': 'K',
    'Λ': 'L',
    'Μ': 'M',
    'Ν': 'N',
    'Ξ': 'X',
    'Ο': 'O',
    'Π': 'P',
    'Ρ': 'R',
    'Σ': 'S',
    'Τ': 'T',
    'Υ': 'Y',
    'Φ': 'F',
    'Χ': 'Ch',
    'Ψ': 'Ps',
    'Ω': 'O',
    'α': 'a',
    'β': 'v',
    'γ': 'g',
    'δ': 'd',
    'ε': 'e',
    'ζ': 'z',
    'η': 'i',
    'θ': 'th',
    'ι': 'i',
    'κ': 'k',
    'λ': 'l',
    'μ': 'm',
    'ν': 'n',
    'ξ': 'x',
    'ο': 'o',
    'π': 'p',
    'ρ': 'r',
    'σ': 's',
    'ς': 's',
    'τ': 't',
    'υ': 'y',
    'φ': 'f',
    'χ': 'ch',
    'ψ': 'ps',
    'ω': 'o',
    'ά': 'a',
    'έ': 'e',
    'ή': 'i',
    'ί': 'i',
    'ό': 'o',
    'ύ': 'y',
    'ώ': 'o',
    'ϊ': 'i',
    'ϋ': 'y',
    'ΐ': 'i',
    'ΰ': 'y',
  };

  /// Transliterates Greek characters in a string to their Latin equivalents.
  static String greekToLatin(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      buffer.write(_map[char] ?? char);
    }
    return buffer.toString();
  }
}
