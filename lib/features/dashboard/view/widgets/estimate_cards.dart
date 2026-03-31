import 'package:flutter/material.dart';

class EstimateCards extends StatelessWidget {
  const EstimateCards({
    super.key,
    required this.currencySymbol,
    required this.perHour,
    required this.perDay,
    required this.perMonth,
  });

  final String currencySymbol;
  final double perHour;
  final double perDay;
  final double perMonth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final cards = [
          _EstimateCard(
            label: 'Per Hour',
            value: '$currencySymbol${perHour.toStringAsFixed(2)}',
          ),
          _EstimateCard(
            label: 'Per Day',
            value: '$currencySymbol${perDay.toStringAsFixed(2)}',
          ),
          _EstimateCard(
            label: 'Per Month',
            value: '$currencySymbol${perMonth.toStringAsFixed(2)}',
          ),
        ];

        return isWide
            ? Row(
                children: [
                  for (final card in cards)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: card,
                      ),
                    ),
                ],
              )
            : Column(
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: card,
                    ),
                ],
              );
      },
    );
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
