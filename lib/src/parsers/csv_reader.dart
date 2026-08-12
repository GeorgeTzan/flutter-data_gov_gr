import 'dart:async';

import 'package:csv/csv.dart';

import '../exceptions/data_gov_exception.dart';
import '../models/resources/csv_options.dart';

/// Incrementally reads bounded CSV bytes as source strings.
final class CsvReader {
  /// Creates a CSV reader without retained state.
  const CsvReader();

  /// Validates headers, including [requiredHeaders], before yielding data rows.
  ///
  /// Preserves cells as strings and reports malformed source records using
  /// one-based `sourceRow` exception details, including the header as row one.
  /// Bounds the header-detection prefix with [CsvOptions.download].
  Stream<Map<String, String>> rows(
    Stream<List<int>> bytes,
    CsvOptions options, {
    List<String> requiredHeaders = const [],
  }) async* {
    final iterator = StreamIterator(
      _text(_boundedBytes(bytes, options), options),
    );
    final detector = _HeaderTerminator();
    final prefix = <String>[];
    var sourceRow = 1;
    try {
      while (detector.eol == null && await iterator.moveNext()) {
        final chunk = iterator.current;
        prefix.add(chunk);
        detector.add(chunk);
      }
      final syntax = _CsvSyntax(options.delimiter);
      Stream<String> replay() async* {
        for (final chunk in prefix) {
          syntax.add(chunk);
          yield chunk;
        }
        prefix.clear();
        while (await iterator.moveNext()) {
          syntax.add(iterator.current);
          yield iterator.current;
        }
        syntax.finish();
      }

      final converter = CsvToListConverter(
        fieldDelimiter: options.delimiter,
        eol: detector.eol ?? (detector.pendingCr ? '\r' : '\n'),
        shouldParseNumbers: false,
        allowInvalid: false,
      );
      List<String>? headers;
      await for (final record in converter.bind(replay())) {
        final cells = record.cast<String>();
        if (headers == null) {
          headers = List.of(cells);
          if (headers.any((header) => header.trim().isEmpty) ||
              headers.toSet().length != headers.length) {
            throw _invalid('CSV headers must be nonempty and unique.', 1);
          }
          final missing = requiredHeaders
              .where((name) => !headers!.contains(name))
              .toList();
          if (missing.isNotEmpty) {
            throw _invalid(
              'CSV is missing required headers.',
              1,
              details: {'missingHeaders': missing},
            );
          }
        } else {
          if (cells.length > headers.length ||
              cells.length < headers.length && !options.padShortRows) {
            throw _invalid('CSV row width does not match headers.', sourceRow);
          }
          yield Map<String, String>.unmodifiable({
            for (var index = 0; index < headers.length; index++)
              headers[index]: index < cells.length ? cells[index] : '',
          });
        }
        sourceRow++;
      }
      if (headers == null && requiredHeaders.isNotEmpty) {
        throw _invalid(
          'CSV is missing required headers.',
          1,
          details: {'missingHeaders': requiredHeaders},
        );
      }
    } on FormatException catch (error) {
      throw _invalid(
        'Resource is not valid CSV in the selected encoding.',
        sourceRow,
        originalError: error,
      );
    } finally {
      await iterator.cancel();
    }
  }

  Stream<List<int>> _boundedBytes(
    Stream<List<int>> bytes,
    CsvOptions options,
  ) async* {
    var size = 0;
    await for (final chunk in bytes) {
      size += chunk.length;
      final limit = options.download.maxBytes;
      if (limit != null && size > limit) {
        throw ByteLimitException('CSV document exceeds decoded byte ceiling.');
      }
      yield chunk;
    }
  }

  Stream<String> _text(Stream<List<int>> bytes, CsvOptions options) async* {
    var first = true;
    await for (var text in options.encoding.decoder.bind(bytes)) {
      if (text.isEmpty) continue;
      if (first) {
        first = false;
        if (text.startsWith('\ufeff')) text = text.substring(1);
      }
      if (text.isNotEmpty) yield text;
    }
  }
}

DecodeException _invalid(
  String message,
  int row, {
  Map<String, Object?> details = const {},
  Object? originalError,
}) => DecodeException(
  message,
  details: {'sourceRow': row, ...details},
  originalError: originalError,
);

final class _HeaderTerminator {
  bool quoted = false;
  bool pendingCr = false;
  String? eol;

  void add(String text) {
    for (final code in text.runes) {
      if (pendingCr) {
        eol = code == 10 ? '\r\n' : '\r';
        return;
      }
      if (code == 34) quoted = !quoted;
      if (!quoted && code == 13) {
        pendingCr = true;
      } else if (!quoted && code == 10) {
        eol = '\n';
        return;
      }
    }
  }
}

enum _CellState { start, unquoted, quoted, closed }

// csv 6 permits stray quotes even with allowInvalid disabled.
final class _CsvSyntax {
  _CsvSyntax(this.delimiter);
  final String delimiter;
  var state = _CellState.start;
  var row = 1;
  var previousCr = false;

  void add(String text) {
    for (final code in text.runes) {
      final character = String.fromCharCode(code);
      if (previousCr && code == 10) {
        previousCr = false;
        continue;
      }
      previousCr = false;
      if (state == _CellState.quoted) {
        if (code == 34) state = _CellState.closed;
      } else if (code == 34) {
        if (state == _CellState.unquoted) {
          throw _invalid('Unexpected quote in CSV cell.', row);
        }
        state = _CellState.quoted;
      } else if (character == delimiter) {
        state = _CellState.start;
      } else if (code == 10 || code == 13) {
        row++;
        state = _CellState.start;
        previousCr = code == 13;
      } else {
        if (state == _CellState.closed) {
          throw _invalid('Unexpected text after closing CSV quote.', row);
        }
        state = _CellState.unquoted;
      }
    }
  }

  void finish() {
    if (state == _CellState.quoted) {
      throw _invalid('Unterminated quoted CSV cell.', row);
    }
  }
}
