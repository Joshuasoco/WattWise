import 'package:equatable/equatable.dart';

class PeripheralProfile extends Equatable {
  const PeripheralProfile({
    required this.id,
    required this.label,
    required this.category,
    required this.watts,
    required this.isEssential,
    required this.source,
  });

  final String id;
  final String label;
  final String category;
  final double watts;
  final bool isEssential;
  final String source;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'category': category,
      'watts': watts,
      'is_essential': isEssential,
      'source': source,
    };
  }

  factory PeripheralProfile.fromMap(Map<String, dynamic> map) {
    return PeripheralProfile(
      id: (map['id'] as String?) ?? '',
      label: (map['label'] as String?) ?? 'Peripheral',
      category: (map['category'] as String?) ?? 'other',
      watts: _toDouble(map['watts']),
      isEssential: (map['is_essential'] as bool?) ?? false,
      source: (map['source'] as String?) ?? 'user',
    );
  }

  static double _toDouble(dynamic raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    return 0;
  }

  @override
  List<Object?> get props => [id, label, category, watts, isEssential, source];
}
