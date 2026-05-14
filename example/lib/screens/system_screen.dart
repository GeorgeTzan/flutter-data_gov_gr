import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_gov_gr/data_gov_gr.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../state.dart';
import '../theme.dart';

class SystemScreen extends StatelessWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sdkState = context.watch<SDKState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('SYSTEM', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('API CONFIGURATION', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white38)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Use Mock Client', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Simulate data without hitting the API'),
                    value: sdkState.useMock,
                    onChanged: (val) => sdkState.toggleMock(val),
                    activeColor: Colors.amber,
                    activeTrackColor: Colors.amber.withAlpha(128),
                  ),
                  if (!sdkState.useMock) ...[
                    const Divider(height: 32),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'API Token',
                        hintText: 'Enter your data.gov.gr token',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => sdkState.updateApiKey(val),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withAlpha(40)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.blueAccent),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Web Browser Hint: If you see "No Internet Connection" in Live Mode, it is likely a CORS restriction. Run Chrome with --disable-web-security for testing.',
                              style: TextStyle(fontSize: 10, color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('RATE LIMIT STATUS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white38)),
          const SizedBox(height: 16),
          const RateLimitMeter(),
        ],
      ),
    );
  }
}

class RateLimitMeter extends StatelessWidget {
  const RateLimitMeter({super.key});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;

    return StreamBuilder<RateLimitStatus>(
      stream: client.rateLimitStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? RateLimitStatus.initial();
        final percentage = status.limit == 0 ? 0.0 : status.remaining / status.limit;
        final color = percentage < 0.2 ? Colors.redAccent : (percentage < 0.5 ? Colors.orangeAccent : CommandCenterTheme.pulseGreen);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${status.remaining} / ${status.limit} remaining', style: const TextStyle(fontWeight: FontWeight.bold)),
                    FaIcon(FontAwesomeIcons.gauge, size: 16, color: color),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.white10,
                  color: color,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                Text(
                  'Auto-reset at: ${status.resetTime.toLocal().toString().split('.').first}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
