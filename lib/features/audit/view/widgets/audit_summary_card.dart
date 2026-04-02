import 'package:flutter/material.dart';

import '../../models/audit_finding.dart';

class AuditSummaryCard extends StatelessWidget {
  const AuditSummaryCard({
    super.key,
    required this.currencySymbol,
    required this.totalMonthlyCost,
    required this.possibleMonthlySavings,
    required this.topFinding,
    required this.confidence,
  });

  final String currencySymbol;
  final double totalMonthlyCost;
  final double possibleMonthlySavings;
  final AuditFinding? topFinding;
  final String confidence;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _HeroMetric(
              label: 'Estimated monthly cost',
              value: '$currencySymbol${totalMonthlyCost.toStringAsFixed(2)}',
            ),
            _HeroMetric(
              label: 'Possible monthly savings',
              value:
                  '$currencySymbol${possibleMonthlySavings.toStringAsFixed(2)}',
            ),
            _HeroMetric(
              label: 'Top waste source',
              value: topFinding?.title ?? 'No major findings yet',
            ),
            Chip(label: Text('Confidence: $confidence')),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
