class SessionModel {
  const SessionModel({
    required this.id,
    required this.durationMinutes,
    required this.ratePerKwh,
    required this.totalCost,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  final String id;
  final int durationMinutes;
  final double ratePerKwh;
  final double totalCost;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  SessionModel copyWith({
    String? id,
    int? durationMinutes,
    double? ratePerKwh,
    double? totalCost,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      ratePerKwh: ratePerKwh ?? this.ratePerKwh,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
