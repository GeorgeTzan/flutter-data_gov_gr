import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../state.dart';
import '../theme.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('CATALOG', style: Theme.of(context).textTheme.headlineMedium),
          backgroundColor: Colors.transparent,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Datasets'),
              Tab(text: 'Topics'),
              Tab(text: 'Providers'),
            ],
            indicatorColor: CommandCenterTheme.secondaryCyan,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        body: const TabBarView(
          children: [
            DatasetListTab(),
            StringListTab(mode: DiscoveryType.topics),
            StringListTab(mode: DiscoveryType.providers),
          ],
        ),
      ),
    );
  }
}

enum DiscoveryType { topics, providers }

class DatasetListTab extends StatelessWidget {
  const DatasetListTab({super.key});

  void _queryDataset(BuildContext context, String id, String title) async {
    final client = context.read<SDKState>().client;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CommandCenterTheme.darkBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withAlpha(13))),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.terminal, size: 16, color: CommandCenterTheme.secondaryCyan),
                      const SizedBox(width: 12),
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: client.generic.query(id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(snapshot.error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                          ),
                        );
                      }
                      final data = snapshot.data ?? [];
                      if (data.isEmpty) return const Center(child: Text('No records returned'));

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              item.toString(),
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white70),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;

    return FutureBuilder<List<DatasetMetadata>>(
      future: client.discovery.listDatasets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorState(error: snapshot.error.toString());
        }

        final datasets = snapshot.data ?? [];
        if (datasets.isEmpty) return const _EmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: datasets.length,
          itemBuilder: (context, index) {
            final ds = datasets[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const FaIcon(FontAwesomeIcons.database, size: 16, color: CommandCenterTheme.secondaryCyan),
                title: Text(ds.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('${ds.publisher} • ${ds.identifier}', style: Theme.of(context).textTheme.labelSmall),
                trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.white24),
                onTap: () => _queryDataset(context, ds.identifier, ds.title),
              ),
            );
          },
        );
      },
    );
  }
}

class StringListTab extends StatelessWidget {
  final DiscoveryType mode;
  const StringListTab({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;
    final future = mode == DiscoveryType.topics ? client.discovery.listTopics() : client.discovery.listProviders();

    return FutureBuilder<List<String>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorState(error: snapshot.error.toString());
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) return const _EmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                title: Text(item, style: const TextStyle(fontSize: 13)),
                leading: Icon(mode == DiscoveryType.topics ? Icons.tag : Icons.business, size: 14, color: Colors.white38),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.boxOpen, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          Text('No results found', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.redAccent, size: 40),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
