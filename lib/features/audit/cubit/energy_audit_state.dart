import 'package:equatable/equatable.dart';

import '../models/energy_audit_result.dart';

enum EnergyAuditStatus { initial, loading, success, failure }

class EnergyAuditState extends Equatable {
  const EnergyAuditState({
    this.status = EnergyAuditStatus.initial,
    this.latestResult,
    this.history = const <EnergyAuditResult>[],
    this.errorMessage,
  });

  final EnergyAuditStatus status;
  final EnergyAuditResult? latestResult;
  final List<EnergyAuditResult> history;
  final String? errorMessage;

  EnergyAuditState copyWith({
    EnergyAuditStatus? status,
    EnergyAuditResult? latestResult,
    List<EnergyAuditResult>? history,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return EnergyAuditState(
      status: status ?? this.status,
      latestResult: latestResult ?? this.latestResult,
      history: history ?? this.history,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, latestResult, history, errorMessage];
}
