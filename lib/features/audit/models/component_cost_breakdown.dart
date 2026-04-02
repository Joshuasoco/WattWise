import 'package:equatable/equatable.dart';

class ComponentCostBreakdown extends Equatable {
  const ComponentCostBreakdown({
    required this.key,
    required this.label,
    required this.watts,
    required this.monthlyCost,
    required this.billShare,
  });

  final String key;
  final String label;
  final double watts;
  final double monthlyCost;
  final double billShare;

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'label': label,
      'watts': watts,
      'monthly_cost': monthlyCost,
      'bill_share': billShare,
    };
  }

  factory ComponentCostBreakdown.fromMap(Map<String, dynamic> map) {
    return ComponentCostBreakdown(
      key: (map['key'] as String?) ?? 'unknown',
      label: (map['label'] as String?) ?? 'Unknown',
      watts: _toDouble(map['watts']),
      monthlyCost: _toDouble(map['monthly_cost']),
      billShare: _toDouble(map['bill_share']),
    );
  }

  static double _toDouble(dynamic raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    return 0;
  }

  @override
  List<Object?> get props => [key, label, watts, monthlyCost, billShare];
}
