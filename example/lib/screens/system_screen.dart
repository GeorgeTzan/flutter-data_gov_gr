import 'package:data_gov_gr/data_gov_gr.dart' hide Theme;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state.dart';
import '../theme.dart';

/// Edits configuration drafts and displays published quota observations.
class SystemScreen extends StatefulWidget {
  /// Creates the configuration page.
  const SystemScreen({super.key});

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  late final TextEditingController _endpoint;
  late final TextEditingController _token;
  late bool _demo;
  String? _error;

  @override
  void initState() {
    super.initState();
    final state = context.read<SDKState>();
    _endpoint = TextEditingController(text: state.actionBaseUrl.toString());
    _token = TextEditingController(text: state.apiKey ?? '');
    _demo = state.demo;
  }

  @override
  void dispose() {
    _endpoint.dispose();
    _token.dispose();
    super.dispose();
  }

  void _apply() {
    try {
      context.read<SDKState>().applyConfiguration(
        actionBaseUrl: Uri.parse(_endpoint.text.trim()),
        apiKey: _token.text,
        demo: _demo,
      );
      setState(() => _error = null);
    } on ArgumentError catch (error) {
      setState(() => _error = error.toString());
    } on FormatException catch (error) {
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SDKState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SYSTEM',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            state.demo ? 'Demo — synthetic data' : 'Real data',
            style: const TextStyle(
              color: CommandCenterTheme.secondaryCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    key: const Key('endpoint'),
                    controller: _endpoint,
                    decoration: const InputDecoration(
                      labelText: 'Action directory URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('token'),
                    controller: _token,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Optional token',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Demo'),
                    subtitle: const Text('Synthetic catalog and files'),
                    value: _demo,
                    onChanged: (value) => setState(() => _demo = value),
                  ),
                  const Text(
                    'Public reads work anonymously. Web access needs your backend; keep private credentials on the server.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _apply, child: const Text('Apply')),
                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'RATE LIMIT STATUS',
            style: TextStyle(letterSpacing: 2, color: Colors.white38),
          ),
          const SizedBox(height: 16),
          RateLimitMeter(key: ObjectKey(state.client)),
        ],
      ),
    );
  }
}

/// Displays absent quota headers as unavailable.
class RateLimitMeter extends StatelessWidget {
  /// Creates the current client quota meter.
  const RateLimitMeter({super.key});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SDKState>().client;
    return StreamBuilder<RateLimitStatus>(
      stream: client.rateLimitStatus,
      initialData: client.currentRateLimitStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? RateLimitStatus.initial();
        final limit = status.limit;
        final remaining = status.remaining;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!status.available)
                  const Text('Unavailable')
                else ...[
                  Text(
                    '${remaining ?? 'Unknown'} / ${limit ?? 'Unknown'} remaining',
                  ),
                  if (limit != null && limit > 0 && remaining != null) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (remaining / limit).clamp(0.0, 1.0),
                      color: CommandCenterTheme.pulseGreen,
                    ),
                  ],
                  if (status.resetAt != null)
                    Text('Resets ${status.resetAt!.toLocal()}'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
