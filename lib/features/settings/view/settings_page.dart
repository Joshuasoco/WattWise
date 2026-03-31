import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _onboardingKeys = <String>[
    'onboarding_complete',
    'cpu_name',
    'gpu_type',
    'gpu_name',
    'ram_gb',
    'ram_sticks',
    'storage_count',
    'storage_type',
    'fan_count',
    'has_rgb',
    'motherboard',
    'chassis_type',
    'electricity_rate',
    'currency_symbol',
    'daily_hours',
  ];

  late final Box<dynamic> _prefs;
  late final TextEditingController _currencyController;
  late final TextEditingController _rateController;
  late final TextEditingController _hoursController;

  @override
  void initState() {
    super.initState();
    _prefs = Hive.box<dynamic>('wattwise_prefs');
    _currencyController = TextEditingController(
      text: (_prefs.get('currency_symbol') as String?) ?? '\u20B1',
    );
    _rateController = TextEditingController(
      text: (((_prefs.get('electricity_rate') as num?) ?? 12).toDouble())
          .toStringAsFixed(2),
    );
    _hoursController = TextEditingController(
      text: (((_prefs.get('daily_hours') as num?) ?? 8).toDouble())
          .toStringAsFixed(1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _currencyController,
            maxLength: 4,
            decoration: const InputDecoration(labelText: 'Currency symbol'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Electricity rate'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hoursController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Daily hours'),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Save Changes')),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _restartOnboarding,
            child: const Text('Restart Onboarding'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
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

    await _prefs.put('currency_symbol', symbol.isEmpty ? '\u20B1' : symbol);
    await _prefs.put('electricity_rate', rate);
    await _prefs.put('daily_hours', hours);

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

    for (final key in _onboardingKeys) {
      await _prefs.delete(key);
    }

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
