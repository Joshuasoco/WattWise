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
        final isWide = constraints.maxWidth > 760;
        final cards = [
          _EstimateCard(
            label: 'Per Hour',
            value: '$currencySymbol${perHour.toStringAsFixed(2)}',
            helper: 'Great for short sessions or quick sanity checks.',
            icon: Icons.schedule_rounded,
          ),
          _EstimateCard(
            label: 'Per Day',
            value: '$currencySymbol${perDay.toStringAsFixed(2)}',
            helper: 'Uses your saved daily usage setting.',
            icon: Icons.today_rounded,
          ),
          _EstimateCard(
            label: 'Per Month',
            value: '$currencySymbol${perMonth.toStringAsFixed(2)}',
            helper: 'Simple 30-day view for budget planning.',
            icon: Icons.calendar_month_rounded,
          ),
        ];

        return isWide
            ? Row(
                children: [
                  for (var i = 0; i < cards.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 6,
                          right: i == cards.length - 1 ? 0 : 6,
                        ),
                        child: cards[i],
                      ),
                    ),
                ],
              )
            : Column(
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: card,
                    ),
                ],
              );
      },
    );
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0EE),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20),
            ),
            const SizedBox(height: 18),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(helper, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
