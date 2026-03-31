enum ComponentType { gpu, ram, storage, fans, rgb }

class ComponentModel {
  const ComponentModel({
    required this.id,
    required this.type,
    required this.label,
    required this.wattage,
  });

  final String id;
  final ComponentType type;
  final String label;
  final double wattage;

  ComponentModel copyWith({
    String? id,
    ComponentType? type,
    String? label,
    double? wattage,
  }) {
    return ComponentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      wattage: wattage ?? this.wattage,
    );
  }
}
