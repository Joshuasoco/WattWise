import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/onboarding_cubit.dart';
import '../../cubit/onboarding_state.dart';

class Step3Terms extends StatelessWidget {
  const Step3Terms({super.key, required this.onAgree});

  final VoidCallback onAgree;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
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
                    'Disclaimer',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'WattWise estimates your electricity cost based on typical hardware wattage values. Results are approximate and not a substitute for a certified energy meter. Actual consumption may vary.',
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('I understand this is an estimate'),
                    value: state.termsAccepted,
                    onChanged: (value) {
                      context.read<OnboardingCubit>().setTermsAccepted(
                        value ?? false,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: state.termsAccepted ? onAgree : null,
                    child: const Text('Agree & Continue'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
