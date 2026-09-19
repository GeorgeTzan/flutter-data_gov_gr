import 'package:data_gov_gr/data_gov_gr.dart' hide Theme;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import '../theme.dart';
import 'resource_screen.dart';

/// Searches and pages through the selected source catalog.
class CatalogScreen extends StatefulWidget {
  /// Creates the catalog page.
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  DataGovClient? _client;
  CancellationController _cancellation = CancellationController();
  final _search = TextEditingController();
  final _pages = <int, Future<CatalogPage>>{};
  final _history = <int>[];
  late Future<CatalogPage> _future;
  String? _query;
  int _offset = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final client = context.watch<SDKState>().client;
    if (!identical(client, _client)) {
      _client = client;
      _reset();
    }
  }

  void _reset() {
    _cancellation.cancel('Catalog replaced.');
    _cancellation = CancellationController();
    _pages.clear();
    _history.clear();
    _offset = 0;
    _future = _load(0);
  }

  Future<CatalogPage> _load(int offset) => _pages.putIfAbsent(
    offset,
    () => _client!.catalog.search(
      CatalogQuery(text: _query, offset: offset),
      cancellation: _cancellation.signal,
    ),
  );

  void _submit(String value) {
    final query = value.trim().isEmpty ? null : value.trim();
    if (query == _query) return;
    setState(() {
      _query = query;
      _reset();
    });
  }

  void _next(CatalogPage page) => setState(() {
    _history.add(_offset);
    _offset = page.offset + page.entries.length;
    _future = _load(_offset);
  });

  void _previous() => setState(() {
    _offset = _history.removeLast();
    _future = _load(_offset);
  });

  @override
  void dispose() {
    _cancellation.cancel('Catalog closed.');
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('CATALOG', style: Theme.of(context).textTheme.headlineMedium),
      backgroundColor: Colors.transparent,
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              labelText: 'Search catalog',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () => _submit(_search.text),
                icon: const Icon(Icons.search),
              ),
            ),
            onSubmitted: _submit,
          ),
        ),
        Expanded(
          child: FutureBuilder<CatalogPage>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Catalog unavailable: ${snapshot.error}'),
                  ),
                );
              }
              final page = snapshot.requireData;
              return Column(
                children: [
                  Text('${page.total} published entries'),
                  Expanded(
                    child: page.entries.isEmpty
                        ? const Center(child: Text('No results found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: page.entries.length,
                            itemBuilder: (context, index) {
                              final entry = page.entries[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.storage,
                                    color: CommandCenterTheme.secondaryCyan,
                                  ),
                                  title: Text(entry.title ?? entry.name),
                                  subtitle: Text(
                                    '${entry.kind} • ${entry.resources.length} resources',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          EntryScreen(entryId: entry.id),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _history.isEmpty ? null : _previous,
                          child: const Text('Previous page'),
                        ),
                        TextButton(
                          onPressed:
                              page.entries.isNotEmpty &&
                                  page.offset + page.entries.length < page.total
                              ? () => _next(page)
                              : null,
                          child: const Text('Next page'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

/// Shows published entry metadata and every resource before selection.
class EntryScreen extends StatefulWidget {
  /// Loads the selected entry identifier.
  const EntryScreen({super.key, required this.entryId});

  /// The selected catalog entry ID.
  final String entryId;

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  DataGovClient? _client;
  CancellationController _cancellation = CancellationController();
  late Future<CatalogEntry> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final client = context.watch<SDKState>().client;
    if (!identical(client, _client)) {
      _client = client;
      _load();
    }
  }

  void _load() {
    _cancellation.cancel('Entry replaced.');
    _cancellation = CancellationController();
    _future = _client!.catalog.getEntry(
      widget.entryId,
      cancellation: _cancellation.signal,
    );
  }

  @override
  void didUpdateWidget(EntryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entryId != widget.entryId) _load();
  }

  @override
  void dispose() {
    _cancellation.cancel('Entry closed.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('RESOURCES')),
    body: FutureBuilder<CatalogEntry>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Entry unavailable: ${snapshot.error}'));
        }
        final entry = snapshot.requireData;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (context.watch<SDKState>().demo)
              const Text('Demo — synthetic data'),
            Text(
              entry.title ?? entry.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (entry.description != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(entry.description!),
              ),
            if (entry.publisher != null) Text('Publisher: ${entry.publisher}'),
            if (entry.metadataModified != null)
              Text('Published modification: ${entry.metadataModified!.raw}'),
            const SizedBox(height: 16),
            const Text('Choose a published resource'),
            if (entry.resources.isEmpty) const Text('No resources published'),
            for (final resource in entry.resources)
              Card(
                child: ListTile(
                  title: Text(
                    '${resource.name ?? resource.id} • ${resource.format ?? 'Unknown format'}',
                  ),
                  subtitle: Text(resource.url ?? 'No file URL published'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ResourceScreen(resource: resource),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
