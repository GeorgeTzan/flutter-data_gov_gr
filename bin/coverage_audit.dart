import 'dart:convert';
import 'dart:io';

import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:data_gov_gr/src/audit/catalog_audit.dart';

const _usage = '''Usage: dart run bin/coverage_audit.dart [options]
  --base-url URL       CKAN action directory (default: https://data.gov.gr/api/3/action/)
  --page-size N        Entries requested per page (default: 100)
  --page-delay-ms N    Delay between pages (default: 250)
  --max-entries N      Bound observed entries (default: 500)
  --full              Explicitly remove the entry cap
  --output PATH       Write JSON to this file (default: stdout)
  --help              Show this help

This audits catalog metadata. It does not download or parse resource files.
''';

/// Runs a bounded catalog metadata audit; full traversal requires `--full`.
Future<void> main(List<String> arguments) async {
  try {
    final options = _parse(arguments);
    if (options.containsKey('--help')) {
      stdout.write(_usage);
      return;
    }
    if (options.containsKey('--full') && options.containsKey('--max-entries')) {
      throw ArgumentError('--full and --max-entries cannot be combined.');
    }
    final config = DataGovConfig(
      actionBaseUrl: options['--base-url'] == null
          ? null
          : Uri.parse(options['--base-url']!),
    );
    final pageSize = _integer(options, '--page-size', 100);
    final delay = _integer(options, '--page-delay-ms', 250, allowZero: true);
    final maxEntries = options.containsKey('--full')
        ? null
        : _integer(options, '--max-entries', 500);
    final output = options['--output'];
    if (output != null && output.trim().isEmpty) {
      throw ArgumentError('--output must name a file.');
    }
    final client = DataGovClient(config: config);
    final cancellation = CancellationController();
    final interrupt = ProcessSignal.sigint.watch().listen(
      (_) => cancellation.cancel('Interrupted by user.'),
    );
    try {
      final report = await CatalogAudit(client.catalog).run(
        query: CatalogQuery(pageSize: pageSize),
        maxEntries: maxEntries,
        pageDelay: Duration(milliseconds: delay),
        cancellation: cancellation.signal,
      );
      final json = report.toJson();
      final encoded = '${const JsonEncoder.withIndent('  ').convert(json)}\n';
      if (output == null) {
        stdout.write(encoded);
      } else {
        await File(output).writeAsString(encoded);
        stderr.writeln(
          'Wrote $output: ${json['uniqueEntryCount']} unique entries; complete=${report.complete}; ${json['stopReason']}.',
        );
      }
      if ((json['pageErrors'] as List).isNotEmpty) exitCode = 1;
    } finally {
      await interrupt.cancel();
      client.close();
    }
  } on ArgumentError catch (error) {
    stderr.writeln('Invalid arguments: ${error.message}\n$_usage');
    exitCode = 64;
  } on FormatException catch (error) {
    stderr.writeln('Invalid arguments: ${error.message}\n$_usage');
    exitCode = 64;
  } on FileSystemException catch (error) {
    stderr.writeln('Could not write the audit report: ${error.message}');
    exitCode = 1;
  }
}

Map<String, String?> _parse(List<String> arguments) {
  final result = <String, String?>{};
  const values = {
    '--base-url',
    '--page-size',
    '--page-delay-ms',
    '--max-entries',
    '--output',
  };
  for (var i = 0; i < arguments.length; i++) {
    final flag = arguments[i];
    if (result.containsKey(flag)) throw ArgumentError('Repeated option: $flag');
    if (flag == '--full' || flag == '--help') {
      result[flag] = null;
    } else if (values.contains(flag)) {
      if (++i >= arguments.length || arguments[i].startsWith('--')) {
        throw ArgumentError('Missing value for $flag');
      }
      result[flag] = arguments[i];
    } else {
      throw ArgumentError('Unknown option: $flag');
    }
  }
  return result;
}

int _integer(
  Map<String, String?> options,
  String flag,
  int fallback, {
  bool allowZero = false,
}) {
  if (!options.containsKey(flag)) return fallback;
  final value = int.tryParse(options[flag]!);
  if (value == null || value < (allowZero ? 0 : 1)) {
    throw ArgumentError(
      '$flag must be ${allowZero ? 'a nonnegative' : 'a positive'} integer.',
    );
  }
  return value;
}
