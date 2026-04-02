import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/energy_audit_repository.dart';
import '../../../data/repositories/wattwise_prefs_repository.dart';
import '../cubit/energy_audit_cubit.dart';
import '../cubit/energy_audit_state.dart';
import '../models/energy_audit_result.dart';
import 'widgets/audit_finding_card.dart';
import 'widgets/audit_summary_card.dart';
import 'widgets/audit_tip_card.dart';
import 'widgets/component_breakdown_chart.dart';

class AuditPage extends StatelessWidget {
  const AuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnergyAuditCubit(
        auditRepository: EnergyAuditRepository(),
        prefsRepository: WattwisePrefsRepository(),
      )..loadLatest(),
      child: const _AuditView(),
    );
  }
}

class _AuditView extends StatelessWidget {
  const _AuditView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Energy Audit'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton.icon(
              onPressed: () => context.read<EnergyAuditCubit>().runAudit(),
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Run Audit'),
            ),
          ),
        ],
      ),
      body: BlocBuilder<EnergyAuditCubit, EnergyAuditState>(
        builder: (context, state) {
          if (state.status == EnergyAuditStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == EnergyAuditStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Unable to load audit results.',
              ),
            );
          }

          final result = state.latestResult;
          if (result == null) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No audits yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Run your first audit to get a component-level cost breakdown and optimization tips.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              context.read<EnergyAuditCubit>().runAudit(),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Start Audit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return _AuditResults(result: result);
        },
      ),
    );
  }
}

class _AuditResults extends StatelessWidget {
  const _AuditResults({required this.result});

  final EnergyAuditResult result;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EnergyAuditCubit>();
    final topFinding = result.findings.isEmpty ? null : result.findings.first;
    final tipSavings = result.tips.fold<double>(
      0,
      (sum, tip) => sum + tip.estimatedMonthlySavings,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuditSummaryCard(
                currencySymbol: result.currencySymbol,
                totalMonthlyCost: result.totalMonthlyCost,
                possibleMonthlySavings: tipSavings,
                topFinding: topFinding,
                confidence: result.confidence,
              ),
              const SizedBox(height: 16),
              Text(
                'Component cost breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: ComponentBreakdownChart(
                    breakdowns: result.breakdowns,
                    currencySymbol: result.currencySymbol,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Findings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: AuditFindingCard(findings: result.findings),
                ),
              ),
              const SizedBox(height: 16),
              Text('Tips', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: AuditTipCard(
                    tips: result.tips,
                    currencySymbol: result.currencySymbol,
                    onSnooze: (tipId) => cubit.snoozeTip(tipId),
                    onDismiss: (tipId) => cubit.dismissTip(tipId),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
