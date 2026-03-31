enum DeviceType { laptop, pc, desktop, mini }

class DeviceModel {
  const DeviceModel({
    required this.id,
    required this.type,
    required this.label,
    required this.wattage,
  });

  final String id;
  final DeviceType type;
  final String label;
  final double wattage;

  DeviceModel copyWith({
    String? id,
    DeviceType? type,
    String? label,
    double? wattage,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      wattage: wattage ?? this.wattage,
    );
  }
}
