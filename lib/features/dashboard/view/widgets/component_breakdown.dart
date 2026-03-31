import 'package:flutter/material.dart';

import '../../../../data/models/system_spec_model.dart';

class ComponentBreakdown extends StatelessWidget {
  const ComponentBreakdown({
    super.key,
    required this.spec,
    required this.currencySymbol,
    required this.ratePerKwh,
  });

  final SystemSpecModel spec;
  final String currencySymbol;
  final double ratePerKwh;

  @override
  Widget build(BuildContext context) {
    final rows = <_ComponentRowData>[
      _ComponentRowData(label: 'CPU', watts: spec.cpuTdpWatts),
      _ComponentRowData(label: 'GPU', watts: spec.gpuWatts),
      _ComponentRowData(
        label: 'RAM',
        watts: spec.ramSticks * spec.ramWattsPerStick,
      ),
      _ComponentRowData(
        label: 'Storage',
        watts: spec.storageCount * spec.storageWattsEach,
      ),
      _ComponentRowData(
        label: 'Fans',
        watts: spec.fanCount * spec.fansWattsEach,
      ),
      _ComponentRowData(label: 'RGB', watts: spec.hasRgb ? spec.rgbWatts : 0),
      _ComponentRowData(label: 'Motherboard', watts: spec.motherboardWatts),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Component Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final row in rows)
              _RowTile(
                label: row.label,
                watts: row.watts,
                totalWatts: spec.totalWatts,
                costPerSecond: (row.watts / 1000) * ratePerKwh / 3600,
                currencySymbol: currencySymbol,
              ),
          ],
        ),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.label,
    required this.watts,
    required this.totalWatts,
    required this.costPerSecond,
    required this.currencySymbol,
  });

  final String label;
  final int watts;
  final int totalWatts;
  final double costPerSecond;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final ratio = totalWatts == 0 ? 0.0 : watts / totalWatts;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text('$watts W'),
              const SizedBox(width: 12),
              Text('${(ratio * 100).toStringAsFixed(1)}%'),
              const SizedBox(width: 12),
              Text('$currencySymbol${costPerSecond.toStringAsFixed(4)}/s'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: ratio),
        ],
      ),
    );
  }
}

class _ComponentRowData {
  const _ComponentRowData({required this.label, required this.watts});

  final String label;
  final int watts;
}
