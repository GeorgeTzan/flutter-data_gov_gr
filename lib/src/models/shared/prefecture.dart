import 'package:json_annotation/json_annotation.dart';

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

  final String rawGreekName;
  const Prefecture(this.rawGreekName);
}

extension PrefectureX on Prefecture {
  String get greekName => rawGreekName;

  String get englishName {
    switch (this) {
      case Prefecture.attica: return 'Attica';
      case Prefecture.thessaloniki: return 'Thessaloniki';
      default:
        final name = toString().split('.').last;
        return name[0].toUpperCase() + name.substring(1);
    }
  }
}

class PrefectureConverter implements JsonConverter<Prefecture, String> {
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

  /// Removes accents and converts to uppercase for robust comparison.
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
