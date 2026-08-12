import 'package:flutter/material.dart';

import '../models/timer_state.dart';
import '../service/timer_service.dart';
import 'base_controller.dart';

class TimerPageController extends BaseController {
  final stateListenable = ValueNotifier<TimerState?>(null);
  TimerConfig config = const TimerConfig(
    totalRounds: 5,
    setsPerRound: 2,
    workTime: 40,
  );

  void _onState(TimerState state) {
    stateListenable.value = state;
  }

  Future<void> startTraining(TimerConfig newConfig) async {
    config = newConfig;
    if (await TimerService.instance.isRunningService) return;
    await TimerService.instance.start(config);
  }

  void togglePause() => TimerService.instance.togglePause();

  Future<void> resetApp() async {
    TimerService.instance.reset();
  }

  void applyLiveChanges(TimerConfig newConfig) {
    config = newConfig;
    TimerService.instance.applyLiveChanges(newConfig);
  }

  @override
  void attach(State state) {
    super.attach(state);
    TimerService.instance.addStateCallback(_onState);
  }

  @override
  void dispose() {
    TimerService.instance.removeStateCallback(_onState);
    stateListenable.dispose();
    super.dispose();
  }
}
