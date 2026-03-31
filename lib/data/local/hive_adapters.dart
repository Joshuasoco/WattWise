import 'package:hive_flutter/hive_flutter.dart';

import '../models/component_model.dart';
import '../models/device_model.dart';
import '../models/session_model.dart';

class DeviceTypeAdapter extends TypeAdapter<DeviceType> {
  @override
  final int typeId = 0;

  @override
  DeviceType read(BinaryReader reader) {
    return DeviceType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, DeviceType obj) {
    writer.writeByte(obj.index);
  }
}

class DeviceModelAdapter extends TypeAdapter<DeviceModel> {
  @override
  final int typeId = 1;

  @override
  DeviceModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return DeviceModel(
      id: fields[0] as String,
      type: fields[1] as DeviceType,
      label: fields[2] as String,
      wattage: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.wattage);
  }
}

class ComponentTypeAdapter extends TypeAdapter<ComponentType> {
  @override
  final int typeId = 2;

  @override
  ComponentType read(BinaryReader reader) {
    return ComponentType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ComponentType obj) {
    writer.writeByte(obj.index);
  }
}

class ComponentModelAdapter extends TypeAdapter<ComponentModel> {
  @override
  final int typeId = 3;

  @override
  ComponentModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return ComponentModel(
      id: fields[0] as String,
      type: fields[1] as ComponentType,
      label: fields[2] as String,
      wattage: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ComponentModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.wattage);
  }
}

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 4;

  @override
  SessionModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return SessionModel(
      id: fields[0] as String,
      durationMinutes: fields[1] as int,
      ratePerKwh: fields[2] as double,
      totalCost: fields[3] as double,
      createdAt: fields[4] as DateTime,
      startedAt: fields[5] as DateTime?,
      endedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.durationMinutes)
      ..writeByte(2)
      ..write(obj.ratePerKwh)
      ..writeByte(3)
      ..write(obj.totalCost)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.endedAt);
  }
}
