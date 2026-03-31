import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/onboarding_cubit.dart';
import '../../cubit/onboarding_state.dart';

class Step1Scanning extends StatefulWidget {
  const Step1Scanning({super.key});

  @override
  State<Step1Scanning> createState() => _Step1ScanningState();
}

class _Step1ScanningState extends State<Step1Scanning>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingCubit>().startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.isScanning &&
          !current.isScanning &&
          current.scanError == null,
      listener: (context, state) {
        context.read<OnboardingCubit>().nextStep();
      },
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          final specItems = [
            (
              label: 'CPU',
              value: state.scannedSpecs.cpuName,
              isResolved: state.cpuScanned,
            ),
            (
              label: 'GPU',
              value: state.scannedSpecs.gpuName,
              isResolved: state.gpuScanned,
            ),
            (
              label: 'RAM',
              value: '${state.scannedSpecs.ramGb} GB',
              isResolved: state.ramScanned,
            ),
            (
              label: 'Storage',
              value:
                  '${state.scannedSpecs.storageCount} ${state.scannedSpecs.storageType}',
              isResolved: state.storageScanned,
            ),
            (
              label: 'Motherboard',
              value: state.scannedSpecs.motherboard,
              isResolved: state.motherboardScanned,
            ),
          ];

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 6.28318,
                          child: child,
                        );
                      },
                      child: const SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(strokeWidth: 5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state.isScanning
                          ? 'Scanning your system...'
                          : 'Scan complete',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final item in specItems)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: _ScanStatusRow(
                                  label: item.label,
                                  value: item.value,
                                  isResolved: item.isResolved,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (state.scanError != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        state.scanError!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () =>
                            context.read<OnboardingCubit>().startScan(),
                        child: const Text('Retry Scan'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
}

class _ScanStatusRow extends StatelessWidget {
  const _ScanStatusRow({
    required this.label,
    required this.value,
    required this.isResolved,
  });

  final String label;
  final String value;
  final bool isResolved;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyMedium;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: isResolved ? value : 'Detecting...',
            style: textTheme?.copyWith(
              color: isResolved
                  ? textTheme.color
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: isResolved ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
