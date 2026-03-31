class SessionModel {
  const SessionModel({
    required this.id,
    required this.durationMinutes,
    required this.ratePerKwh,
    required this.totalCost,
    required this.createdAt,
  });

  final String id;
  final int durationMinutes;
  final double ratePerKwh;
  final double totalCost;
  final DateTime createdAt;

  SessionModel copyWith({
    String? id,
    int? durationMinutes,
    double? ratePerKwh,
    double? totalCost,
    DateTime? createdAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      ratePerKwh: ratePerKwh ?? this.ratePerKwh,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
