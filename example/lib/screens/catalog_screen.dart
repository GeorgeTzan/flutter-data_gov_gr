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

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;

    return FutureBuilder<List<DatasetMetadata>>(
      future: client.discovery.listDatasets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Endpoint: query/${ds.identifier}')),
                  );
                },
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
