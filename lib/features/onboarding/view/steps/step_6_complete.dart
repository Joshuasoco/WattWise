import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/onboarding_cubit.dart';
import '../../cubit/onboarding_state.dart';

class Step6Complete extends StatefulWidget {
  const Step6Complete({super.key, required this.onStartTracking});

  final Future<void> Function() onStartTracking;

  @override
  State<Step6Complete> createState() => _Step6CompleteState();
}

class _Step6CompleteState extends State<Step6Complete> {
  bool _expanded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _expanded = true);
      }
    });
  }

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
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    width: _expanded ? 96 : 48,
                    height: _expanded ? 96 : 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D9E75),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You're all set!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'CPU',
                            value: state.confirmedSpecs.cpuName,
                          ),
                          _SummaryRow(
                            label: 'Total watts',
                            value: '${state.confirmedSpecs.totalWatts} W',
                          ),
                          _SummaryRow(
                            label: 'Rate',
                            value:
                                '${state.currencySymbol}${state.electricityRate.toStringAsFixed(2)}/kWh',
                          ),
                          _SummaryRow(
                            label: 'Hours/day',
                            value: state.dailyHours.toStringAsFixed(1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            await widget.onStartTracking();
                            if (mounted) {
                              setState(() => _saving = false);
                            }
                          },
                    child: Text(_saving ? 'Saving...' : 'Start Tracking'),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
