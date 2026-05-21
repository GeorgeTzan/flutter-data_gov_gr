import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../state.dart';
import '../theme.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  Prefecture _selectedPrefecture = Prefecture.attica;

  void _showPrefecturePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommandCenterTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'SELECT PREFECTURE',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Prefecture.values.length,
                itemBuilder: (context, index) {
                  final p = Prefecture.values[index];
                  return ListTile(
                    title: Text(
                      p.englishName,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: p == _selectedPrefecture
                        ? const Icon(
                            Icons.check,
                            color: CommandCenterTheme.secondaryCyan,
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedPrefecture = p);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MONITOR',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        actions: [const PulseIndicator(), const SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'LIQUID FUEL PRICES'),
                TextButton.icon(
                  onPressed: () => _showPrefecturePicker(context),
                  icon: const Icon(Icons.filter_list, size: 16),
                  label: Text(
                    _selectedPrefecture.englishName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: CommandCenterTheme.secondaryCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FuelMonitorModule(prefecture: _selectedPrefecture),
            const SizedBox(height: 32),
            const SectionHeader(title: 'KIMDIS PROCUREMENT'),
            const SizedBox(height: 16),
            const ProcurementMonitorModule(),
            const SizedBox(height: 32),
            const SectionHeader(title: 'NETWORK & INFRASTRUCTURE'),
            const SizedBox(height: 16),
            const TelecomMonitorModule(),
            const SizedBox(height: 32),
            const SectionHeader(title: 'PUBLIC HEALTH & SAFETY'),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: HealthMonitorModule()),
                SizedBox(width: 12),
                Expanded(child: EnvironmentMonitorModule()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PulseIndicator extends StatelessWidget {
  const PulseIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final useMock = context.watch<SDKState>().useMock;
    final color = useMock ? Colors.amber : CommandCenterTheme.pulseGreen;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(128),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          useMock ? 'MOCK MODE' : 'LIVE API',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
        color: CommandCenterTheme.secondaryCyan.withAlpha(178),
      ),
    );
  }
}

class FuelMonitorModule extends StatelessWidget {
  final Prefecture prefecture;
  const FuelMonitorModule({super.key, required this.prefecture});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;

    return FutureBuilder<List<FuelStation>>(
      key: ValueKey(prefecture),
      future: client.fuel.query().wherePrefecture(prefecture).fetch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return ErrorCard(error: snapshot.error.toString());
        }

        final stations = snapshot.data ?? [];

        return AnimationLimiter(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stations.length > 3 ? 3 : stations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final station = stations[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: StationCard(station: station)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ProcurementMonitorModule extends StatelessWidget {
  const ProcurementMonitorModule({super.key});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;

    return FutureBuilder<List<ProcurementDecision>>(
      future: client.procurement.getKimdisDecisions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorCard(error: snapshot.error.toString());
        }

        final data = snapshot.data ?? [];
        if (data.isEmpty) return const SizedBox();
        final latest = data.first;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        latest.subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '€${latest.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  latest.organization,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'ADAM: ${latest.adam}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TelecomMonitorModule extends StatelessWidget {
  const TelecomMonitorModule({super.key});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;

    return FutureBuilder<List<InternetTraffic>>(
      future: client.telecom.getInternetTraffic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        final data = snapshot.data ?? [];
        if (data.isEmpty) return const SizedBox();
        final latest = data.last;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GR-IX Internet Traffic',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FaIcon(
                      FontAwesomeIcons.networkWired,
                      size: 14,
                      color: Colors.blue[300],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _TrafficMetric(
                      label: 'INBOUND',
                      value: '${latest.inbound.toStringAsFixed(1)} Gbps',
                    ),
                    const SizedBox(width: 24),
                    _TrafficMetric(
                      label: 'OUTBOUND',
                      value: '${latest.outbound.toStringAsFixed(1)} Gbps',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrafficMetric extends StatelessWidget {
  final String label;
  final String value;
  const _TrafficMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: CommandCenterTheme.secondaryCyan,
          ),
        ),
      ],
    );
  }
}

class EnvironmentMonitorModule extends StatelessWidget {
  const EnvironmentMonitorModule({super.key});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;

    return FutureBuilder<List<ForestFire>>(
      future: client.environment.getForestFires(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        final data = snapshot.data ?? [];
        final count = data.length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FaIcon(
                  FontAwesomeIcons.fire,
                  size: 14,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Forest Fires',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StationCard extends StatelessWidget {
  final FuelStation station;
  const StationCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withAlpha(13),
              child: const FaIcon(
                FontAwesomeIcons.gasPump,
                size: 16,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.brand,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    station.address,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${station.price.toStringAsFixed(3)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CommandCenterTheme.secondaryCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  station.fuelType.englishName,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HealthMonitorModule extends StatelessWidget {
  const HealthMonitorModule({super.key});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;

    return FutureBuilder<List<VaccinationData>>(
      future: client.health.getVaccinationStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        final data = snapshot.data ?? [];
        final total = data.isEmpty
            ? 0
            : data.fold<int>(0, (sum, item) => sum + item.dayTotal);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FaIcon(
                  FontAwesomeIcons.syringe,
                  size: 14,
                  color: CommandCenterTheme.secondaryCyan,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vaccinations',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
                Text(
                  total > 1000
                      ? '${(total / 1000).toStringAsFixed(1)}k'
                      : total.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String error;
  const ErrorCard({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withAlpha(26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.redAccent, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          error,
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      ),
    );
  }
}
