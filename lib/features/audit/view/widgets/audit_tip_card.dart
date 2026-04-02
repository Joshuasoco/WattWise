import 'package:flutter/material.dart';

import '../../models/audit_tip.dart';

class AuditTipCard extends StatelessWidget {
  const AuditTipCard({
    super.key,
    required this.tips,
    required this.currencySymbol,
    required this.onSnooze,
    required this.onDismiss,
  });

  final List<AuditTip> tips;
  final String currencySymbol;
  final ValueChanged<String> onSnooze;
  final ValueChanged<String> onDismiss;

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) {
      return const Text('No actionable tips generated yet.');
    }

    return Column(
      children: [
        for (final tip in tips)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(tip.title),
            subtitle: Text(
              '${tip.body}\nPotential savings: $currencySymbol${tip.estimatedMonthlySavings.toStringAsFixed(2)}/month',
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => onSnooze(tip.id),
                  child: const Text('Snooze 7d'),
                ),
                TextButton(
                  onPressed: () => onDismiss(tip.id),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
