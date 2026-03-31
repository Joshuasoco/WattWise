import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../calculator/cubit/cost_calculator_cubit.dart';
import '../cubit/settings_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  String _currency = 'PHP';
  ThemeMode _themeMode = ThemeMode.light;
  final TextEditingController _rateController = TextEditingController(
    text: '12',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Watt Tracker')),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_currentStep + 1) / 3),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIntroStep(),
                _buildPreferencesStep(),
                _buildRateStep(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  OutlinedButton(onPressed: _goBack, child: const Text('Back')),
                const Spacer(),
                FilledButton(
                  onPressed: _currentStep == 2 ? _finish : _goNext,
                  child: Text(_currentStep == 2 ? 'Finish' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroStep() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Quick Setup',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Set your preferred currency, theme, and default electricity rate to start accurate cost tracking right away.',
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _currency,
            items: const [
              DropdownMenuItem(value: 'PHP', child: Text('PHP')),
              DropdownMenuItem(value: 'USD', child: Text('USD')),
              DropdownMenuItem(value: 'EUR', child: Text('EUR')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _currency = value);
            },
            decoration: const InputDecoration(
              labelText: 'Currency',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {_themeMode},
            onSelectionChanged: (selection) {
              setState(() => _themeMode = selection.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRateStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Default Electricity Rate',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Rate per kWh',
              hintText: 'e.g. 12.50',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This value is used for initial calculations and can be changed later in Settings.',
          ),
        ],
      ),
    );
  }

  void _goBack() {
    if (_currentStep == 0) return;
    setState(() => _currentStep -= 1);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goNext() {
    if (_currentStep >= 2) return;
    setState(() => _currentStep += 1);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    final parsedRate = double.tryParse(_rateController.text.trim());
    if (parsedRate == null || parsedRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid electricity rate greater than 0.'),
        ),
      );
      return;
    }

    final settingsCubit = context.read<SettingsCubit>();
    final calculatorCubit = context.read<CostCalculatorCubit>();

    await settingsCubit.setCurrencyCode(_currency);
    await settingsCubit.setThemeMode(_themeMode);
    await settingsCubit.setDefaultRatePerKwh(parsedRate);
    await settingsCubit.completeOnboarding();
    calculatorCubit.setRatePerKwh(parsedRate);

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rateController.dispose();
    super.dispose();
  }
}
