import 'package:flutter/material.dart';

class CostTicker extends StatelessWidget {
  const CostTicker({
    super.key,
    required this.currencySymbol,
    required this.totalCost,
    required this.costPerSecond,
  });

  final String currencySymbol;
  final double totalCost;
  final double costPerSecond;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: totalCost),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          builder: (context, value, _) {
            return Text(
              '$currencySymbol${value.toStringAsFixed(4)}',
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          '$currencySymbol${costPerSecond.toStringAsFixed(4)} per second',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
