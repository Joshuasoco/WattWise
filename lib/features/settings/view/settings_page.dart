import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/system_spec_model.dart';
import '../../../data/repositories/wattage_preset_repository.dart';
import '../../../data/repositories/wattwise_prefs_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final WattwisePrefsRepository _prefsRepository;
  final WattagePresetRepository _presetRepository = WattagePresetRepository();
  late final TextEditingController _currencyController;
  late final TextEditingController _rateController;
  late final TextEditingController _hoursController;

  @override
  void initState() {
    super.initState();
    _prefsRepository = WattwisePrefsRepository();
    _currencyController = TextEditingController(
      text: _prefsRepository.currencySymbol,
    );
    _rateController = TextEditingController(
      text: _prefsRepository.electricityRate.toStringAsFixed(2),
    );
    _hoursController = TextEditingController(
      text: _prefsRepository.dailyHours.toStringAsFixed(1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rate = double.tryParse(_rateController.text.trim()) ??
        _prefsRepository.electricityRate;
    final hours = double.tryParse(_hoursController.text.trim()) ??
        _prefsRepository.dailyHours;
    final symbol = _currencyController.text.trim().isEmpty
        ? '\u20B1'
        : _currencyController.text.trim();
    final spec = _resolvedSpec();
    final hourlyCost = (spec.totalWatts / 1000) * rate;
    final dailyCost = hourlyCost * hours;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 920;

                return Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Chip(
                                    avatar: Icon(Icons.tune_rounded),
                                    label: Text('Tracking preferences'),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Fine-tune your numbers',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'These values affect the live dashboard and all forward-looking cost projections.',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _currencyController,
                                    maxLength: 4,
                                    decoration: const InputDecoration(
                                      labelText: 'Currency symbol',
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _rateController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Electricity rate',
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _hoursController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Daily hours',
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                  const SizedBox(height: 18),
                                  FilledButton(
                                    onPressed: _save,
                                    child: const Text('Save Changes'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reset setup',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Restart onboarding if your hardware changed or if you want to rescan the device from scratch.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      OutlinedButton(
                                        onPressed: _restartOnboarding,
                                        child: const Text('Restart Onboarding'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () => context.go('/dashboard'),
                                        child: const Text('Back to Dashboard'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: wide ? 16 : 0, height: wide ? 0 : 16),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _SettingsPreviewCard(
                            symbol: symbol,
                            rate: rate,
                            hours: hours,
                            hourlyCost: hourlyCost,
                            dailyCost: dailyCost,
                            totalWatts: spec.totalWatts,
                          ),
                          const SizedBox(height: 16),
                          _HardwareSummaryCard(spec: spec),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  SystemSpecModel _resolvedSpec() {
    final saved = _prefsRepository.systemSpec;
    return saved.copyWith(
      cpuTdpWatts: _presetRepository.resolveCpuTdp(saved.cpuName),
      gpuWatts: _presetRepository.resolveGpuWatts(saved.gpuName, saved.gpuType),
      storageWattsEach: saved.storageType == 'HDD' ? 7 : 3,
      rgbWatts: saved.hasRgb ? 10 : 0,
    );
  }

  Future<void> _save() async {
    final rate = double.tryParse(_rateController.text.trim());
    final hours = double.tryParse(_hoursController.text.trim());
    final symbol = _currencyController.text.trim();

    if (rate == null || rate <= 0 || hours == null || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values.')),
      );
      return;
    }

    await _prefsRepository.saveUsagePreferences(
      electricityRate: rate,
      currencySymbol: symbol,
      dailyHours: hours,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved.')));
    }
  }

  Future<void> _restartOnboarding() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restart onboarding?'),
          content: const Text(
            'This clears your saved hardware and setup preferences so the app opens the onboarding flow again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _prefsRepository.resetOnboarding();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Onboarding reset.')));
    context.go('/onboarding');
  }

  @override
  void dispose() {
    _currencyController.dispose();
    _rateController.dispose();
    _hoursController.dispose();
    super.dispose();
  }
}

class _SettingsPreviewCard extends StatelessWidget {
  const _SettingsPreviewCard({
    required this.symbol,
    required this.rate,
    required this.hours,
    required this.hourlyCost,
    required this.dailyCost,
    required this.totalWatts,
  });

  final String symbol;
  final double rate;
  final double hours;
  final double hourlyCost;
  final double dailyCost;
  final int totalWatts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live preview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              'As you edit your settings, this shows the current model the dashboard will use.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _PreviewRow(label: 'Power profile', value: '$totalWatts W'),
            _PreviewRow(
              label: 'Rate',
              value: '$symbol${rate.toStringAsFixed(2)}/kWh',
            ),
            _PreviewRow(
              label: 'Usage',
              value: '${hours.toStringAsFixed(1)} hrs/day',
            ),
            _PreviewRow(
              label: 'Per hour',
              value: '$symbol${hourlyCost.toStringAsFixed(2)}',
            ),
            _PreviewRow(
              label: 'Per day',
              value: '$symbol${dailyCost.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _HardwareSummaryCard extends StatelessWidget {
  const _HardwareSummaryCard({required this.spec});

  final SystemSpecModel spec;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved hardware profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            _PreviewRow(label: 'CPU', value: spec.cpuName),
            _PreviewRow(label: 'GPU', value: spec.gpuName),
            _PreviewRow(
              label: 'RAM',
              value: '${spec.ramGb} GB / ${spec.ramSticks} sticks',
            ),
            _PreviewRow(
              label: 'Storage',
              value: '${spec.storageCount} ${spec.storageType}',
            ),
            _PreviewRow(
              label: 'Chassis',
              value: spec.chassisType.replaceAll('_', ' '),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(label)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
