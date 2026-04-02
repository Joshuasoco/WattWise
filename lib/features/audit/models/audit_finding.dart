import 'package:equatable/equatable.dart';

class AuditFinding extends Equatable {
  const AuditFinding({
    required this.id,
    required this.type,
    required this.severity,
    required this.confidence,
    required this.title,
    required this.description,
    required this.estimatedMonthlyImpact,
    required this.componentKeys,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String severity;
  final String confidence;
  final String title;
  final String description;
  final double estimatedMonthlyImpact;
  final List<String> componentKeys;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'confidence': confidence,
      'title': title,
      'description': description,
      'estimated_monthly_impact': estimatedMonthlyImpact,
      'component_keys': componentKeys,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AuditFinding.fromMap(Map<String, dynamic> map) {
    return AuditFinding(
      id: (map['id'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'unknown',
      severity: (map['severity'] as String?) ?? 'low',
      confidence: (map['confidence'] as String?) ?? 'low',
      title: (map['title'] as String?) ?? 'Untitled finding',
      description: (map['description'] as String?) ?? '',
      estimatedMonthlyImpact: _toDouble(map['estimated_monthly_impact']),
      componentKeys: _toStringList(map['component_keys']),
      createdAt: DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static double _toDouble(dynamic raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    return 0;
  }

  static List<String> _toStringList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<String>().toList(growable: false);
    }
    return const <String>[];
  }

  @override
  List<Object?> get props => [
    id,
    type,
    severity,
    confidence,
    title,
    description,
    estimatedMonthlyImpact,
    componentKeys,
    createdAt,
  ];
}
