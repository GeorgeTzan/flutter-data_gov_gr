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
    final client = context.watch<SDKState>().client;

    return Scaffold(
      appBar: AppBar(
        title: Text('CATALOG', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<DatasetMetadata>>(
        future: client.discovery.listDatasets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.circleExclamation, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text('Discovery Error', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: MainAxisAlignment.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          final datasets = snapshot.data ?? [];

          if (datasets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.boxOpen, size: 48, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text('No datasets found', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            );
          }

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
                  subtitle: Text(
                    '${ds.publisher} • ${ds.identifier}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
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
      ),
    );
  }
}
