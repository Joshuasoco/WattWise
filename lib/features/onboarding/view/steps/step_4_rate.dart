import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/onboarding_cubit.dart';

class Step4Rate extends StatefulWidget {
  const Step4Rate({super.key, required this.onContinue});

  final void Function(double rate, String symbol) onContinue;

  @override
  State<Step4Rate> createState() => _Step4RateState();
}

class _Step4RateState extends State<Step4Rate> {
  late final TextEditingController _symbolController;
  late final TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingCubit>().state;
    _symbolController = TextEditingController(text: state.currencySymbol);
    _rateController = TextEditingController(
      text: state.electricityRate.toStringAsFixed(2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsedRate = double.tryParse(_rateController.text.trim()) ?? 0;
    final symbol = _symbolController.text.trim().isEmpty
        ? '₱'
        : _symbolController.text.trim();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What's your electricity rate?",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _symbolController,
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'Currency symbol'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rateController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Rate',
                  hintText: 'e.g. 13.47',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              const Text('Check your latest electric bill for the exact rate.'),
              const SizedBox(height: 12),
              Text(
                'At this rate, 1 kWh costs $symbol${parsedRate.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: parsedRate > 0
                    ? () => widget.onContinue(parsedRate, symbol)
                    : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _rateController.dispose();
    super.dispose();
  }
}
