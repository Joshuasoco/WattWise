import 'package:equatable/equatable.dart';

class AuditTip extends Equatable {
  const AuditTip({
    required this.id,
    required this.findingId,
    required this.actionType,
    required this.title,
    required this.body,
    required this.estimatedWattsSaved,
    required this.estimatedMonthlySavings,
    required this.confidence,
    this.dismissedUntil,
    this.isDismissed = false,
  });

  final String id;
  final String findingId;
  final String actionType;
  final String title;
  final String body;
  final double estimatedWattsSaved;
  final double estimatedMonthlySavings;
  final String confidence;
  final DateTime? dismissedUntil;
  final bool isDismissed;

  AuditTip copyWith({
    DateTime? dismissedUntil,
    bool? isDismissed,
  }) {
    return AuditTip(
      id: id,
      findingId: findingId,
      actionType: actionType,
      title: title,
      body: body,
      estimatedWattsSaved: estimatedWattsSaved,
      estimatedMonthlySavings: estimatedMonthlySavings,
      confidence: confidence,
      dismissedUntil: dismissedUntil ?? this.dismissedUntil,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'finding_id': findingId,
      'action_type': actionType,
      'title': title,
      'body': body,
      'estimated_watts_saved': estimatedWattsSaved,
      'estimated_monthly_savings': estimatedMonthlySavings,
      'confidence': confidence,
      'dismissed_until': dismissedUntil?.toIso8601String(),
      'is_dismissed': isDismissed,
    };
  }

  factory AuditTip.fromMap(Map<String, dynamic> map) {
    return AuditTip(
      id: (map['id'] as String?) ?? '',
      findingId: (map['finding_id'] as String?) ?? '',
      actionType: (map['action_type'] as String?) ?? 'unknown',
      title: (map['title'] as String?) ?? 'Untitled tip',
      body: (map['body'] as String?) ?? '',
      estimatedWattsSaved: _toDouble(map['estimated_watts_saved']),
      estimatedMonthlySavings: _toDouble(map['estimated_monthly_savings']),
      confidence: (map['confidence'] as String?) ?? 'low',
      dismissedUntil:
          DateTime.tryParse((map['dismissed_until'] as String?) ?? ''),
      isDismissed: (map['is_dismissed'] as bool?) ?? false,
    );
  }

  static double _toDouble(dynamic raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    return 0;
  }

  @override
  List<Object?> get props => [
    id,
    findingId,
    actionType,
    title,
    body,
    estimatedWattsSaved,
    estimatedMonthlySavings,
    confidence,
    dismissedUntil,
    isDismissed,
  ];
}
