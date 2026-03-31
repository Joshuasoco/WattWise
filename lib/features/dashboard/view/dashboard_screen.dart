import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
          LiveTimerCubit(prefsBox: Hive.box<dynamic>('wattwise_prefs')),
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
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    state.spec.cpuName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Chip(label: Text(state.spec.chassisType.replaceAll('_', ' '))),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.settings),
              ),
              IconButton(
                onPressed: () {
                  final cubit = context.read<LiveTimerCubit>();
                  if (state.isRunning) {
                    cubit.pauseTimer();
                  } else {
                    cubit.startTimer();
                  }
                },
                icon: Icon(state.isRunning ? Icons.pause : Icons.play_arrow),
              ),
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
            label: Text(state.isRunning ? 'Pause' : 'Resume'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),
                CostTicker(
                  currencySymbol: state.currencySymbol,
                  totalCost: state.totalCostAccumulated,
                  costPerSecond: state.costPerSecond,
                ),
                const SizedBox(height: 20),
                EstimateCards(
                  currencySymbol: state.currencySymbol,
                  perHour: state.perHour,
                  perDay: state.perDay,
                  perMonth: state.perMonth,
                ),
                const SizedBox(height: 14),
                ComponentBreakdown(
                  spec: state.spec,
                  currencySymbol: state.currencySymbol,
                  ratePerKwh: state.ratePerKwh,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
