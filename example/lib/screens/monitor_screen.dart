import 'dart:convert';
import 'package:data_gov_gr/data_gov_gr.dart' hide Theme;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import '../theme.dart';

/// Displays bounded verified source observations with their provenance.
class MonitorScreen extends StatefulWidget {
  /// Creates the published observations page.
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  DataGovClient? _client;
  CancellationController _cancellation = CancellationController();
  CancellationController _fireCancellation = CancellationController();
  Future<_Sample?>? _traffic;
  Future<_Sample?>? _vaccinations;
  Future<CatalogEntry>? _fireEntry;
  Future<_Sample?>? _fire;
  String? _selectedFire;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<SDKState>();
    if (identical(state.client, _client)) return;
    _cancellation.cancel('Monitor configuration replaced.');
    _fireCancellation.cancel('Monitor configuration replaced.');
    _cancellation = CancellationController();
    _fireCancellation = CancellationController();
    _client = state.client;
    _traffic = null;
    _vaccinations = null;
    _fireEntry = null;
    _fire = null;
    _selectedFire = null;
    if (state.demo) return;
    final client = state.client;
    _traffic = _one(
      client.telecom
          .internetTraffic(cancellation: _cancellation.signal)
          .map(
            (row) => _Sample(row.provenance, row.raw, {
              'Published date': row.date.raw,
              'Average incoming': row.avgIn,
              'Average outgoing': row.avgOut,
              'Maximum incoming': row.maxIn,
              'Maximum outgoing': row.maxOut,
            }),
          ),
    );
    _vaccinations = _one(
      client.health
          .vaccinations(cancellation: _cancellation.signal)
          .map(
            (row) => _Sample(row.provenance, row.raw, {
              'Area': row.area,
              'Area identifier': row.areaId,
              'Reference date': row.referenceDate.raw,
              'Day total': row.dayTotal,
              'Total vaccinations': row.totalVaccinations,
              'Distinct persons': row.totalDistinctPersons,
            }),
          ),
    );
    _fireEntry = client.catalog.getEntry(
      'mcp_forest_fires',
      cancellation: _cancellation.signal,
    );
  }

  Future<_Sample?> _one(Stream<_Sample> samples) async {
    final rows = await samples.take(1).toList();
    return rows.isEmpty ? null : rows.single;
  }

  void _selectFire(String? id) {
    if (id == null || id == _selectedFire) return;
    _fireCancellation.cancel('Fire resource replaced.');
    _fireCancellation = CancellationController();
    setState(() {
      _selectedFire = id;
      _fire = _one(
        _client!.environment
            .forestFires(resourceId: id, cancellation: _fireCancellation.signal)
            .map(
              (row) => _Sample(row.provenance, row.raw, {
                'Published start': row.startTime.raw,
                'Published end': row.endTime?.raw,
                'Fire station': row.fireStation,
                'Prefecture': row.prefecture,
                'Location': row.location,
                'Forest area burned': row.forestAreaBurned,
                'Firefighters': row.firefighters,
              }),
            ),
      );
    });
  }

  @override
  void dispose() {
    _cancellation.cancel('Monitor closed.');
    _fireCancellation.cancel('Monitor closed.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final demo = context.watch<SDKState>().demo;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MONITOR',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            demo ? 'Demo — synthetic data' : 'PUBLISHED OBSERVATIONS',
            style: const TextStyle(
              color: CommandCenterTheme.secondaryCyan,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          if (demo)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Provider samples are unavailable in Demo. Open Catalog to explore the synthetic files.',
                ),
              ),
            )
          else ...[
            const Text(
              'Historical source samples. These are not current operational reports. Published units remain unspecified.',
            ),
            const SizedBox(height: 16),
            _SampleCard(title: 'Internet traffic', future: _traffic),
            _SampleCard(title: 'Vaccinations', future: _vaccinations),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Forest fires',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<CatalogEntry>(
                      future: _fireEntry,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const LinearProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text(
                            'Fire sources unavailable: ${snapshot.error}',
                          );
                        }
                        final resources = snapshot.requireData.resources;
                        if (resources.isEmpty) {
                          return const Text('No fire resources published');
                        }
                        return DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedFire,
                          hint: const Text('Choose a published fire resource'),
                          items: [
                            for (final resource in resources)
                              DropdownMenuItem(
                                value: resource.id,
                                child: Text(
                                  '${resource.name ?? resource.id} • ${resource.format ?? 'Unknown format'}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: _selectFire,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_fire != null)
              _SampleCard(title: 'Selected fire source', future: _fire),
          ],
        ],
      ),
    );
  }
}

class _Sample {
  const _Sample(this.provenance, this.raw, this.fields);
  final SourceProvenance provenance;
  final Map<String, Object?> raw;
  final Map<String, Object?> fields;
}

class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.title, required this.future});
  final String title;
  final Future<_Sample?>? future;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FutureBuilder<_Sample?>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Sample unavailable: ${snapshot.error}');
              }
              final sample = snapshot.data;
              if (sample == null) return const Text('No records published');
              final provenance = sample.provenance;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final field in sample.fields.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${field.key}: ${field.value ?? 'Not published'}',
                      ),
                    ),
                  const Divider(height: 24),
                  Text('Resource: ${provenance.resourceId}'),
                  SelectableText('Source: ${provenance.sourceUrl}'),
                  Text(
                    'Published modification: ${provenance.publishedModified?.raw ?? 'Not published'}',
                  ),
                  Text(
                    'Retrieved: ${provenance.retrievedAt.toIso8601String()}',
                  ),
                  if (provenance.sourceRow != null)
                    Text('Source row position: ${provenance.sourceRow}'),
                  ExpansionTile(
                    title: const Text('All published values'),
                    children: [
                      SelectableText(
                        const JsonEncoder.withIndent('  ').convert(sample.raw),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}
