import 'package:flutter/material.dart';

import '../../models/component_cost_breakdown.dart';

class ComponentBreakdownChart extends StatelessWidget {
  const ComponentBreakdownChart({
    super.key,
    required this.breakdowns,
    required this.currencySymbol,
  });

  final List<ComponentCostBreakdown> breakdowns;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (breakdowns.isEmpty) {
      return const Text('No component breakdown available yet.');
    }

    return Column(
      children: [
        for (final item in breakdowns)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BreakdownRow(
              label: item.label,
              watts: item.watts,
              monthlyCost: item.monthlyCost,
              billShare: item.billShare,
              currencySymbol: currencySymbol,
            ),
          ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.watts,
    required this.monthlyCost,
    required this.billShare,
    required this.currencySymbol,
  });

  final String label;
  final double watts;
  final double monthlyCost;
  final double billShare;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final sharePct = billShare < 0.1
        ? (billShare * 100).toStringAsFixed(1)
        : (billShare * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${watts.toStringAsFixed(0)} W',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 14),
            Text(
              '$currencySymbol${monthlyCost.toStringAsFixed(2)}/mo',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 14),
            Text('$sharePct%', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: billShare.clamp(0, 1).toDouble()),
      ],
    );
  }
}
