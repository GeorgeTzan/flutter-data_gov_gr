import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../state.dart';
import '../theme.dart';

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MONITOR', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        actions: [
          const PulseIndicator(),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'LIQUID FUEL PRICES'),
            const SizedBox(height: 16),
            const FuelMonitorModule(),
            const SizedBox(height: 32),
            const SectionHeader(title: 'HEALTH STATISTICS'),
            const SizedBox(height: 16),
            const HealthMonitorModule(),
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
              )
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
  const FuelMonitorModule({super.key});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;

    return FutureBuilder<List<FuelStation>>(
      future: client.fuel.query().wherePrefecture(Prefecture.attica).fetch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final station = stations[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: StationCard(station: station),
                  ),
                ),
              );
            },
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
              child: const FaIcon(FontAwesomeIcons.gasPump, size: 16, color: Colors.amber),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.brand, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(station.address, style: Theme.of(context).textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                Text(station.fuelType.englishName, style: Theme.of(context).textTheme.labelSmall),
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
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];
        if (data.isEmpty) return const SizedBox();

        final total = data.fold<int>(0, (sum, item) => sum + item.dayTotal);

        return Card(
          color: CommandCenterTheme.secondaryCyan.withAlpha(13),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daily Doses (Total)', style: TextStyle(color: Colors.white54)),
                    FaIcon(FontAwesomeIcons.syringe, size: 16, color: CommandCenterTheme.secondaryCyan),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
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
        child: Text(error, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
      ),
    );
  }
}
