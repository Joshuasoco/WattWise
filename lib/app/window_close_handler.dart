import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

import '../data/services/tray_service.dart';
import '../features/dashboard/cubit/live_timer_cubit.dart';

mixin WindowCloseHandler<T extends StatefulWidget> on State<T>, WindowListener {
  LiveTimerCubit? _timerCubit;

  void initCloseHandler(LiveTimerCubit timerCubit) {
    if (!Platform.isWindows) {
      return;
    }

    _timerCubit = timerCubit;
    windowManager.addListener(this);
    unawaited(windowManager.setPreventClose(true));
  }

  @override
  void onWindowClose() async {
    if (!Platform.isWindows) {
      return;
    }

    final trayService = TrayService();
    final isTracking =
        (_timerCubit?.state.isRunning ?? false) || trayService.isInitialized;

    if (trayService.isQuitRequested) {
      trayService.resetQuitRequested();
      await windowManager.setPreventClose(false);
      await windowManager.destroy();
      return;
    }

    if (isTracking) {
      await windowManager.hide();
      return;
    }

    await trayService.dispose();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }
}
