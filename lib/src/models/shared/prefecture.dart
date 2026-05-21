import 'package:json_annotation/json_annotation.dart';

/// Represents the 51 prefectures of Greece used for filtering datasets.
enum Prefecture {
  attica('ΑΤΤΙΚΗΣ'),
  thessaloniki('ΘΕΣΣΑΛΟΝΙΚΗΣ'),
  aitoloakarnania('ΑΙΤΩΛΟΑΚΑΡΝΑΝΙΑΣ'),
  argolida('ΑΡΓΟΛΙΔΟΣ'),
  arkadia('ΑΡΚΑΔΙΑΣ'),
  arta('ΑΡΤΗΣ'),
  achaia('ΑΧΑΪΑΣ'),
  boeotia('ΒΟΙΩΤΙΑΣ'),
  grevena('ΓΡΕΒΕΝΩΝ'),
  drama('ΔΡΑΜΑΣ'),
  dodecanese('ΔΩΔΕΚΑΝΗΣΟΥ'),
  evros('ΕΒΡΟΥ'),
  evia('ΕΥΒΟΙΑΣ'),
  evrytania('ΕΥΡΥΤΑΝΙΑΣ'),
  zakynthos('ΖΑΚΥΝΘΟΥ'),
  ileia('ΗΛΕΙΑΣ'),
  imathia('ΗΜΑΘΙΑΣ'),
  heraklion('ΗΡΑΚΛΕΙΟΥ'),
  thesprotia('ΘΕΣΠΡΩΤΙΑΣ'),
  ioannina('ΙΩΑΝΝΙΝΩΝ'),
  kavala('ΚΑΒΑΛΑΣ'),
  karditsa('ΚΑΡΔΙΤΣΗΣ'),
  kastoria('ΚΑΣΤΟΡΙΑΣ'),
  corfu('ΚΕΡΚΥΡΑΣ'),
  kefalonia('ΚΕΦΑΛΛΗΝΙΑΣ'),
  kilkis('ΚΙΛΚΙΣ'),
  kozani('ΚΟΖΑΝΗΣ'),
  corinthia('ΚΟΡΙΝΘΙΑΣ'),
  cyclades('ΚΥΚΛΑΔΩΝ'),
  laconia('ΛΑΚΩΝΙΑΣ'),
  larissa('ΛΑΡΙΣΗΣ'),
  lasithi('ΛΑΣΙΘΙΟΥ'),
  lesbos('ΛΕΣΒΟΥ'),
  lefkada('ΛΕΥΚΑΔΟΣ'),
  magnesia('ΜΑΓΝΗΣΙΑΣ'),
  messinia('ΜΕΣΣΗΝΙΑΣ'),
  xanthi('ΞΑΝΘΗΣ'),
  pella('ΠΕΛΛΗΣ'),
  pieria('ΠΙΕΡΙΑΣ'),
  preveza('ΠΡΕΒΕΖΗΣ'),
  rethymno('ΡΕΘΥΜΝΗΣ'),
  rhodope('ΡΟΔΟΠΗΣ'),
  samos('ΣΑΜΟΥ'),
  serres('ΣΕΡΡΩΝ'),
  trikala('ΤΡΙΚΑΛΩΝ'),
  fthiotida('ΦΘΙΩΤΙΔΟΣ'),
  florina('ΦΛΩΡΙΝΗΣ'),
  focis('ΦΩΚΙΔΟΣ'),
  chalkidiki('ΧΑΛΚΙΔΙΚΗΣ'),
  chania('ΧΑΝΙΩΝ'),
  chios('ΧΙΟΥ');

  /// The uppercase Greek name of the prefecture as used in the API.
  final String rawGreekName;

  /// Creates a [Prefecture] with its uppercase Greek name.
  const Prefecture(this.rawGreekName);
}

/// Extension methods for [Prefecture].
extension PrefectureX on Prefecture {
  /// Returns the uppercase Greek name of the prefecture.
  String get greekName => rawGreekName;

  /// Returns the English capitalized name of the prefecture.
  String get englishName {
    switch (this) {
      case Prefecture.attica:
        return 'Attica';
      case Prefecture.thessaloniki:
        return 'Thessaloniki';
      default:
        final name = toString().split('.').last;
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}

/// A JSON converter for mapping prefecture names to [Prefecture] enum values.
class PrefectureConverter implements JsonConverter<Prefecture, String> {
  /// Creates a new [PrefectureConverter] instance.
  const PrefectureConverter();

  @override
  Prefecture fromJson(String json) {
    final normalizedInput = _normalize(json);
    return Prefecture.values.firstWhere(
      (e) => _normalize(e.rawGreekName) == normalizedInput,
      orElse: () => throw ArgumentError('Unknown Prefecture: $json'),
    );
  }

  @override
  String toJson(Prefecture object) => object.rawGreekName;

  String _normalize(String input) {
    return input
        .toUpperCase()
        .replaceAll('Ά', 'Α')
        .replaceAll('Έ', 'Ε')
        .replaceAll('Ή', 'Η')
        .replaceAll('Ί', 'Ι')
        .replaceAll('Ό', 'Ο')
        .replaceAll('Ύ', 'Υ')
        .replaceAll('Ώ', 'Ω')
        .replaceAll('Ϊ', 'Ι')
        .replaceAll('Ϋ', 'Υ');
  }
}
