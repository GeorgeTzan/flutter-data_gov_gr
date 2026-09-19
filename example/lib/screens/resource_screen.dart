import 'dart:async';
import 'dart:convert';
import 'package:data_gov_gr/data_gov_gr.dart' hide Theme;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../downloads/download.dart';
import '../state.dart';

/// Inspects a caller-selected resource and previews a bounded source sample.
class ResourceScreen extends StatefulWidget {
  /// Inspects an explicitly selected published resource.
  const ResourceScreen({super.key, required this.resource});

  /// The complete metadata of the selected resource.
  final ResourceMetadata resource;

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  DataGovClient? _client;
  CancellationController _cancellation = CancellationController();
  final _rows = <Map<String, Object?>>[];
  int _generation = 0;
  bool _loading = false;
  String? _error;
  String? _saved;
  String? _source;
  DateTime? _observedAt;
  String? _observedLabel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final client = context.watch<SDKState>().client;
    if (!identical(client, _client)) {
      _client = client;
      _reset();
    }
  }

  @override
  void didUpdateWidget(ResourceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.resource, widget.resource)) _reset();
  }

  void _cancel() {
    _generation++;
    _cancellation.cancel('Resource operation replaced or closed.');
    _cancellation = CancellationController();
  }

  void _reset() {
    _cancel();
    _rows.clear();
    _error = null;
    _saved = null;
    _observedAt = null;
    _observedLabel = null;
    _loading = false;
    final resource = widget.resource;
    _source = resource.datastoreActive == true
        ? (resource.fileUri == null ? 'datastore' : null)
        : 'file';
  }

  bool _current(int generation) => mounted && generation == _generation;

  String _failure(Object error) =>
      error is DataGovException && error.statusCode != null
      ? 'HTTP ${error.statusCode}: ${error.message}'
      : error.toString();

  Future<void> _preview() async {
    _cancel();
    final generation = _generation;
    final cancellation = _cancellation;
    setState(() {
      _rows.clear();
      _error = null;
      _saved = null;
      _observedAt = null;
      _observedLabel = null;
      _loading = true;
    });
    try {
      final resource = widget.resource;
      final Stream<Map<String, Object?>> rows;
      if (_source == 'datastore') {
        rows = _client!.datastore.records(
          resource.id,
          DataStoreQuery(limit: 100),
          cancellation: cancellation.signal,
        );
      } else {
        final format = resource.format?.toLowerCase().trim();
        if (const {'csv', 'text/csv', 'application/csv'}.contains(format)) {
          rows = _client!.resources.csvRows(
            resource,
            cancellation: cancellation.signal,
          );
        } else if (const {'json', 'application/json'}.contains(format)) {
          final document = await _client!.resources.readJson(
            resource,
            cancellation: cancellation.signal,
          );
          if (!_current(generation)) return;
          rows = Stream.fromIterable(
            _client!.resources.jsonObjectRows(document).take(100),
          );
        } else {
          throw UnsupportedError(
            'Preview unavailable for ${resource.format ?? 'unknown format'}. You can save the published file.',
          );
        }
      }
      await for (final row in rows.take(100)) {
        if (!_current(generation)) return;
        setState(() => _rows.add(row));
      }
      if (_current(generation)) {
        setState(() {
          _observedAt = DateTime.now().toUtc();
          _observedLabel = 'Preview completed (UTC)';
        });
      }
    } catch (error) {
      if (_current(generation)) {
        setState(() => _error = 'Preview failed: ${_failure(error)}');
      }
    } finally {
      cancellation.cancel('Preview complete.');
      if (_current(generation)) setState(() => _loading = false);
    }
  }

  Future<void> _download() async {
    _cancel();
    final generation = _generation;
    final cancellation = _cancellation;
    setState(() {
      _error = null;
      _saved = null;
      _observedAt = null;
      _observedLabel = null;
      _loading = true;
    });
    try {
      final resource = widget.resource;
      final result = await _client!.resources.download(
        resource,
        cancellation: cancellation.signal,
      );
      if (!_current(generation)) {
        cancellation.cancel();
        return;
      }
      final extension =
          resource.format?.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') ??
          'download';
      await saveDownload('${resource.id}.$extension', result.bytes);
      if (_current(generation)) {
        setState(() {
          _saved = 'File saved';
          _observedAt = result.provenance.retrievedAt.toUtc();
          _observedLabel = 'Retrieved (UTC)';
        });
      }
    } catch (error) {
      if (_current(generation)) {
        setState(() => _error = 'Save failed: ${_failure(error)}');
      }
    } finally {
      cancellation.cancel('Save complete.');
      if (_current(generation)) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    return Scaffold(
      appBar: AppBar(title: const Text('RESOURCE')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (context.watch<SDKState>().demo)
                    const Text('Demo — synthetic data'),
                  Text(
                    resource.name ?? resource.id,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('Format: ${resource.format ?? 'Unknown'}'),
                  SelectableText(resource.url ?? 'No file URL published'),
                  if (resource.modified != null)
                    Text('Published modification: ${resource.modified!.raw}'),
                  if (resource.datastoreActive == true &&
                      resource.fileUri != null)
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _source,
                      hint: const Text('Choose a source'),
                      items: const [
                        DropdownMenuItem(
                          value: 'datastore',
                          child: Text('DataStore table'),
                        ),
                        DropdownMenuItem(
                          value: 'file',
                          child: Text('Published file'),
                        ),
                      ],
                      onChanged: (value) => setState(() {
                        _cancel();
                        _source = value;
                        _rows.clear();
                        _loading = false;
                        _error = null;
                        _saved = null;
                        _observedAt = null;
                        _observedLabel = null;
                      }),
                    ),
                  if (const {
                    'json',
                    'application/json',
                  }.contains(resource.format?.toLowerCase()))
                    const Text('JSON preview reads a document up to 8 MiB.'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      FilledButton(
                        onPressed: _loading || _source == null
                            ? null
                            : _preview,
                        child: const Text('Preview first 100 rows'),
                      ),
                      OutlinedButton(
                        onPressed: _loading || resource.fileUri == null
                            ? null
                            : _download,
                        child: const Text('Save file'),
                      ),
                      if (_loading)
                        TextButton(
                          onPressed: () => setState(() {
                            _cancel();
                            _loading = false;
                          }),
                          child: const Text('Cancel'),
                        ),
                    ],
                  ),
                  const Text(downloadNotice),
                  if (_saved != null) Text(_saved!),
                  if (_observedAt != null)
                    Text('$_observedLabel: ${_observedAt!.toIso8601String()}'),
                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  Text('${_rows.length} rows shown'),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverToBoxAdapter(child: LinearProgressIndicator()),
          SliverList.builder(
            itemCount: _rows.length,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(_rows[index]),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
