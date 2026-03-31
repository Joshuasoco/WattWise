import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/session_model.dart';
import '../../../data/repositories/wattage_repository.dart';
import '../../../shared/utils/currency.dart';
import '../../../shared/widgets/section_card.dart';
import '../../history/cubit/history_cubit.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../settings/cubit/settings_state.dart';
import '../cubit/cost_calculator_cubit.dart';
import '../cubit/cost_calculator_state.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  late String _selectedDeviceId;

  @override
  void initState() {
    super.initState();
    _selectedDeviceId = WattageRepository.devicePresets.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final devices = WattageRepository.devicePresets;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: BlocBuilder<CostCalculatorCubit, CostCalculatorState>(
        builder: (context, calcState) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final dailyEstimate = calcState.totalCost;
              final monthlyEstimate = dailyEstimate * 30;
              final liveCost = calcState.isSessionRunning
                  ? calcState.liveSessionCost
                  : calcState.totalCost;
              final hasValidRate = calcState.ratePerKwh > 0;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  final tickerCard = SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Cost Ticker',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(end: liveCost),
                          duration: const Duration(milliseconds: 350),
                          builder: (context, value, _) {
                            return Text(
                              formatCurrency(settingsState.currencyCode, value),
                              style: Theme.of(context).textTheme.headlineMedium,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Total watts: ${calcState.totalWatts.toStringAsFixed(1)} W',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Session timer: ${_formatDuration(calcState.elapsedSessionSeconds)}',
                        ),
                      ],
                    ),
                  );

                  final estimateCard = SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimates',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Daily: ${formatCurrency(settingsState.currencyCode, dailyEstimate)}',
                        ),
                        Text(
                          'Monthly: ${formatCurrency(settingsState.currencyCode, monthlyEstimate)}',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Usage hours/day: ${calcState.hours.toStringAsFixed(1)}',
                        ),
                        Slider(
                          value: calcState.hours.clamp(0, 24),
                          min: 0,
                          max: 24,
                          divisions: 24,
                          label: calcState.hours.toStringAsFixed(0),
                          onChanged: (value) {
                            context.read<CostCalculatorCubit>().setHours(value);
                          },
                        ),
                        if (!hasValidRate)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Set a rate greater than 0 in Config or Settings.',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                      ],
                    ),
                  );

                  final deviceCard = SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Device Selector',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDeviceId,
                          items: [
                            for (final d in devices)
                              DropdownMenuItem<String>(
                                value: d.id,
                                child: Text(
                                  '${d.label} (${d.wattage.toStringAsFixed(0)}W)',
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            final selected = devices.firstWhere(
                              (d) => d.id == value,
                            );
                            setState(() => _selectedDeviceId = value);
                            context.read<CostCalculatorCubit>().setDevice(
                              selected,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () async {
                            final repository = context
                                .read<WattageRepository>();
                            final historyCubit = context.read<HistoryCubit>();
                            final messenger = ScaffoldMessenger.of(context);
                            final calculatorCubit = context
                                .read<CostCalculatorCubit>();

                            if (!hasValidRate) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Electricity rate must be greater than 0.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (!calcState.isSessionRunning) {
                              calculatorCubit.startSession();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Session started'),
                                ),
                              );
                              return;
                            }

                            calculatorCubit.stopSession();
                            final endedAt = DateTime.now();
                            final startedAt = calcState.sessionStartedAt;
                            final session = SessionModel(
                              id: endedAt.microsecondsSinceEpoch.toString(),
                              durationMinutes:
                                  (calcState.elapsedSessionSeconds / 60)
                                      .round(),
                              ratePerKwh: calcState.ratePerKwh,
                              totalCost: calcState.liveSessionCost,
                              createdAt: endedAt,
                              startedAt: startedAt,
                              endedAt: endedAt,
                            );

                            await repository.saveSession(session);
                            historyCubit.loadSessions();
                            calculatorCubit.resetSessionTimer();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Session stopped and saved'),
                              ),
                            );
                          },
                          icon: Icon(
                            calcState.isSessionRunning
                                ? Icons.stop_circle_outlined
                                : Icons.play_circle_outline,
                          ),
                          label: Text(
                            calcState.isSessionRunning
                                ? 'Stop Session'
                                : 'Start Session',
                          ),
                        ),
                      ],
                    ),
                  );

                  final cards = [deviceCard, tickerCard, estimateCard];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: wide
                        ? Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final card in cards)
                                SizedBox(
                                  width: (constraints.maxWidth - 56) / 2,
                                  child: card,
                                ),
                            ],
                          )
                        : Column(children: cards),
                  );
                },
              );
            },
          );
        },
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
