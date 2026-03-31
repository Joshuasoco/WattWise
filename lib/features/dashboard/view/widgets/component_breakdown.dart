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
      _ComponentRowData(label: 'CPU', watts: spec.cpuTdpWatts, icon: Icons.memory_rounded),
      _ComponentRowData(label: 'GPU', watts: spec.gpuWatts, icon: Icons.videogame_asset_rounded),
      _ComponentRowData(
        label: 'RAM',
        watts: spec.ramSticks * spec.ramWattsPerStick,
        icon: Icons.storage_rounded,
      ),
      _ComponentRowData(
        label: 'Storage',
        watts: spec.storageCount * spec.storageWattsEach,
        icon: Icons.save_rounded,
      ),
      _ComponentRowData(
        label: 'Fans',
        watts: spec.fanCount * spec.fansWattsEach,
        icon: Icons.air_rounded,
      ),
      _ComponentRowData(
        label: 'RGB',
        watts: spec.hasRgb ? spec.rgbWatts : 0,
        icon: Icons.light_mode_rounded,
      ),
      _ComponentRowData(
        label: 'Motherboard',
        watts: spec.motherboardWatts,
        icon: Icons.developer_board_rounded,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Component breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'See which parts make up the bulk of your estimated power draw and cost share.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RowTile(
                  data: row,
                  totalWatts: spec.totalWatts,
                  costPerSecond: (row.watts / 1000) * ratePerKwh / 3600,
                  currencySymbol: currencySymbol,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.data,
    required this.totalWatts,
    required this.costPerSecond,
    required this.currencySymbol,
  });

  final _ComponentRowData data;
  final int totalWatts;
  final double costPerSecond;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final ratio = totalWatts == 0 ? 0.0 : data.watts / totalWatts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(data.icon, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.label, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${(ratio * 100).toStringAsFixed(1)}% of total load',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${data.watts} W',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$currencySymbol${costPerSecond.toStringAsFixed(4)}/s',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: ratio,
              backgroundColor: const Color(0xFFE9E9E6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentRowData {
  const _ComponentRowData({
    required this.label,
    required this.watts,
    required this.icon,
  });

  final String label;
  final int watts;
  final IconData icon;
}
