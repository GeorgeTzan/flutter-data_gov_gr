import 'dart:convert';

import 'download_options.dart';

/// Immutable CSV decoding options; cells remain source strings.
final class CsvOptions {
  /// Creates validated CSV options with one non-quote, non-linebreak delimiter.
  factory CsvOptions({
    String delimiter = ',',
    Encoding encoding = utf8,
    bool padShortRows = false,
    DownloadOptions download = DownloadOptions.defaults,
  }) {
    if (delimiter.runes.length != 1 ||
        const {'\n', '\r', '"'}.contains(delimiter)) {
      throw ArgumentError.value(
        delimiter,
        'delimiter',
        'Must be one non-quote, non-linebreak character',
      );
    }
    return CsvOptions._(delimiter, encoding, padShortRows, download);
  }

  const CsvOptions._(
    this.delimiter,
    this.encoding,
    this.padShortRows,
    this.download,
  );

  /// Validated defaults usable in optional argument declarations.
  static const defaults = CsvOptions._(
    ',',
    utf8,
    false,
    DownloadOptions.defaults,
  );

  /// The source column delimiter.
  final String delimiter;

  /// The source character encoding.
  final Encoding encoding;

  /// Whether shorter rows may be padded with empty string cells.
  final bool padShortRows;

  /// The decoded download bounds applied before parsing.
  final DownloadOptions download;
}
