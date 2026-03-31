import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/wattwise_prefs_repository.dart';
import '../cubit/live_timer_cubit.dart';
import '../cubit/live_timer_state.dart';
import 'widgets/component_breakdown.dart';
import 'widgets/cost_ticker.dart';
import 'widgets/estimate_cards.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LiveTimerCubit(prefsRepository: WattwisePrefsRepository()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveTimerCubit, LiveTimerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.spec.cpuName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Live electricity tracking for this machine',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Chip(
                  label: Text(state.spec.chassisType.replaceAll('_', ' ')),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Settings',
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              final cubit = context.read<LiveTimerCubit>();
              if (state.isRunning) {
                cubit.pauseTimer();
              } else {
                cubit.startTimer();
              }
            },
            icon: Icon(state.isRunning ? Icons.pause : Icons.play_arrow),
            label: Text(state.isRunning ? 'Pause Tracking' : 'Resume Tracking'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 900;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _TopPill(
                              icon: state.isRunning
                                  ? Icons.play_circle_fill_rounded
                                  : Icons.pause_circle_filled_rounded,
                              label:
                                  state.isRunning ? 'Tracking live' : 'Paused',
                            ),
                            _TopPill(
                              icon: Icons.schedule_rounded,
                              label:
                                  '${state.dailyHours.toStringAsFixed(1)} hrs/day',
                            ),
                            _TopPill(
                              icon: Icons.receipt_long_rounded,
                              label:
                                  '${state.currencySymbol}${state.ratePerKwh.toStringAsFixed(2)}/kWh',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 10,
                                child: CostTicker(
                                  currencySymbol: state.currencySymbol,
                                  totalCost: state.totalCostAccumulated,
                                  costPerSecond: state.costPerSecond,
                                  totalWatts: state.spec.totalWatts,
                                  elapsedSeconds: state.elapsedSeconds,
                                  isRunning: state.isRunning,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 4,
                                child: _DashboardContextPanel(state: state),
                              ),
                            ],
                          )
                        else ...[
                          CostTicker(
                            currencySymbol: state.currencySymbol,
                            totalCost: state.totalCostAccumulated,
                            costPerSecond: state.costPerSecond,
                            totalWatts: state.spec.totalWatts,
                            elapsedSeconds: state.elapsedSeconds,
                            isRunning: state.isRunning,
                          ),
                          const SizedBox(height: 14),
                          _DashboardContextPanel(state: state),
                        ],
                        const SizedBox(height: 22),
                        Text(
                          'Projection snapshot',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        EstimateCards(
                          currencySymbol: state.currencySymbol,
                          perHour: state.perHour,
                          perDay: state.perDay,
                          perMonth: state.perMonth,
                        ),
                        const SizedBox(height: 22),
                        ComponentBreakdown(
                          spec: state.spec,
                          currencySymbol: state.currencySymbol,
                          ratePerKwh: state.ratePerKwh,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardContextPanel extends StatelessWidget {
  const _DashboardContextPanel({required this.state});

  final LiveTimerState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session context', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            _ContextRow(
              label: 'Elapsed',
              value: _formatDuration(state.elapsedSeconds),
            ),
            _ContextRow(
              label: 'Power profile',
              value: '${state.spec.totalWatts} W',
            ),
            _ContextRow(
              label: 'Today estimate',
              value:
                  '${state.currencySymbol}${state.perDay.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Text(
                state.isRunning
                    ? 'Tracking is currently live. Pause if you want the ticker to stop accumulating cost.'
                    : 'Tracking is paused. Resume whenever you want the live cost ticker to continue.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final hh = hours.toString().padLeft(2, '0');
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}

class _ContextRow extends StatelessWidget {
  const _ContextRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TopPill extends StatelessWidget {
  const _TopPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
