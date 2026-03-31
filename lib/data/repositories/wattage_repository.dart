import 'package:hive_flutter/hive_flutter.dart';

import '../local/hive_boxes.dart';
import '../models/component_model.dart';
import '../models/device_model.dart';
import '../models/session_model.dart';

class WattageRepository {
  WattageRepository({
    Box<DeviceModel>? devicesBox,
    Box<ComponentModel>? componentsBox,
    Box<SessionModel>? sessionsBox,
  }) : _devicesBox = devicesBox ?? Hive.box<DeviceModel>(HiveBoxes.devices),
       _componentsBox =
           componentsBox ?? Hive.box<ComponentModel>(HiveBoxes.components),
       _sessionsBox = sessionsBox ?? Hive.box<SessionModel>(HiveBoxes.sessions);

  final Box<DeviceModel> _devicesBox;
  final Box<ComponentModel> _componentsBox;
  final Box<SessionModel> _sessionsBox;

  static const List<DeviceModel> devicePresets = [
    DeviceModel(
      id: 'device_laptop',
      type: DeviceType.laptop,
      label: 'Laptop',
      wattage: 65,
    ),
    DeviceModel(
      id: 'device_pc',
      type: DeviceType.pc,
      label: 'PC',
      wattage: 180,
    ),
    DeviceModel(
      id: 'device_desktop',
      type: DeviceType.desktop,
      label: 'Desktop',
      wattage: 250,
    ),
    DeviceModel(
      id: 'device_mini',
      type: DeviceType.mini,
      label: 'Mini PC',
      wattage: 90,
    ),
  ];

  static const List<ComponentModel> componentPresets = [
    ComponentModel(
      id: 'cmp_gpu_mid',
      type: ComponentType.gpu,
      label: 'GPU Midrange',
      wattage: 180,
    ),
    ComponentModel(
      id: 'cmp_ram_16',
      type: ComponentType.ram,
      label: 'RAM 16GB',
      wattage: 8,
    ),
    ComponentModel(
      id: 'cmp_storage_ssd',
      type: ComponentType.storage,
      label: 'Storage SSD',
      wattage: 5,
    ),
    ComponentModel(
      id: 'cmp_fans_3',
      type: ComponentType.fans,
      label: 'Fans x3',
      wattage: 9,
    ),
    ComponentModel(
      id: 'cmp_rgb_std',
      type: ComponentType.rgb,
      label: 'RGB Strip',
      wattage: 12,
    ),
  ];

  List<DeviceModel> getSavedDevices() =>
      _devicesBox.values.toList(growable: false);

  List<ComponentModel> getSavedComponents() =>
      _componentsBox.values.toList(growable: false);

  List<SessionModel> getSavedSessions() =>
      _sessionsBox.values.toList(growable: false);

  Future<void> seedPresetsIfEmpty() async {
    if (_devicesBox.isEmpty) {
      final deviceMap = {for (final preset in devicePresets) preset.id: preset};
      await _devicesBox.putAll(deviceMap);
    }

    if (_componentsBox.isEmpty) {
      final componentMap = {
        for (final preset in componentPresets) preset.id: preset,
      };
      await _componentsBox.putAll(componentMap);
    }
  }

  Future<void> upsertDevice(DeviceModel device) async {
    await _devicesBox.put(device.id, device);
  }

  Future<void> upsertComponent(ComponentModel component) async {
    await _componentsBox.put(component.id, component);
  }

  Future<void> saveSession(SessionModel session) async {
    await _sessionsBox.put(session.id, session);
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessionsBox.delete(sessionId);
  }
}
