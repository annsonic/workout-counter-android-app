import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../models/timer_state.dart';
import 'timer_service_handler.dart';

typedef TimerStateCallback = void Function(TimerState state);

class TimerService {
  TimerService._();

  static final TimerService instance = TimerService._();

  Future<void> _requestPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  void init() {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'coach_timer_service',
        channelName: 'Coach Timer Service',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(200), // 200ms 輪詢
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// 啟動背景計時服務
  Future<void> start(TimerConfig config) async {
    await _requestPermissions();

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
          serviceId: 600,
          notificationTitle: '教練計時器執行中',
          notificationText: '準備開始...',
          callback: startTimerService,
        );

    if (result is ServiceRequestFailure) {
      throw result.error;
    }

    // 服務啟動後，把初始設定送進背景 isolate
    FlutterForegroundTask.sendDataToTask({
      'command': 'start',
      'config': config.toJson(),
    });
  }

  Future<void> stop() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();
    if (result is ServiceRequestFailure) {
      throw result.error;
    }
  }

  void togglePause() {
    FlutterForegroundTask.sendDataToTask({'command': 'togglePause'});
  }

  void reset() {
    FlutterForegroundTask.sendDataToTask({'command': 'reset'});
  }

  void applyLiveChanges(TimerConfig config) {
    FlutterForegroundTask.sendDataToTask({
      'command': 'applyLiveChanges',
      'config': config.toJson(),
    });
  }

  Future<bool> get isRunningService => FlutterForegroundTask.isRunningService;

  // ------------- Service callback -------------
  final List<TimerStateCallback> _stateCallbacks = [];

  void _onReceiveTaskData(Object data) {
    if (data is! Map<String, dynamic>) return;

    if (TimerState.containsData(data)) {
      final TimerState state = TimerState.fromJson(data);
      for (final callback in _stateCallbacks.toList()) {
        callback(state);
      }
    }
  }

  void addStateCallback(TimerStateCallback callback) {
    if (!_stateCallbacks.contains(callback)) {
      _stateCallbacks.add(callback);
    }
  }

  void removeStateCallback(TimerStateCallback callback) {
    _stateCallbacks.remove(callback);
  }
}
