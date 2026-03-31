import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/onboarding_cubit.dart';

class Step5Hours extends StatefulWidget {
  const Step5Hours({super.key, required this.onContinue});

  final ValueChanged<double> onContinue;

  @override
  State<Step5Hours> createState() => _Step5HoursState();
}

class _Step5HoursState extends State<Step5Hours> {
  late double _hours;

  @override
  void initState() {
    super.initState();
    _hours = context.read<OnboardingCubit>().state.dailyHours;
  }

  @override
  Widget build(BuildContext context) {
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
                'How many hours a day do you use this device?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  _hours.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: _hours,
                min: 1,
                max: 24,
                divisions: 46,
                label: _hours.toStringAsFixed(1),
                onChanged: (value) => setState(() => _hours = value),
              ),
              const SizedBox(height: 8),
              const Text('Used for daily and monthly cost projections'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => widget.onContinue(_hours),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
