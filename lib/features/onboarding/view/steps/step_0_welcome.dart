import 'package:flutter/material.dart';

class Step0Welcome extends StatelessWidget {
  const Step0Welcome({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 96,
                color: Color(0xFF1D9E75),
              ),
              const SizedBox(height: 20),
              Text(
                'Know what your PC really costs.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'WattWise scans your hardware and tracks electricity cost in real time.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              FilledButton(onPressed: onNext, child: const Text('Get Started')),
            ],
          ),
        ),
      ),
    );
  }
}
