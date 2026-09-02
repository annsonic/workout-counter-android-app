import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

import '../models/timer_state.dart';

@pragma('vm:entry-point')
void startTimerService() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.setTaskHandler(TimerServiceHandler());
}

const List<String> _chineseNums = [
  '零',
  '一',
  '二',
  '三',
  '四',
  '五',
  '六',
  '七',
  '八',
  '九',
  '十',
];

String _cn(int n) =>
    (n >= 0 && n < _chineseNums.length) ? _chineseNums[n] : '$n';

class TimerServiceHandler extends TaskHandler {
  final FlutterTts _tts = FlutterTts();

  TimerConfig _config = const TimerConfig(
    totalRounds: 5,
    setsPerRound: 2,
    workTime: 40,
  );
  TimerState _state = TimerState.initial;

  DateTime? _phaseStartTime;
  int _phaseDuration = 0;
  Timer? _finishTimer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initTts();
  }

  Future<void> _initTts() async {
    // 1. 確認是否支援 zh-TW，並嘗試挑選明確的繁體中文語音（避免 fallback 到其他腔調）
    try {
      final bool isAvailable = await _tts.isLanguageAvailable('zh-TW');
      // dev.log('TimerServiceHandler::zh-TW available: $isAvailable');

      if (isAvailable) {
        await _tts.setLanguage('zh-TW');
      } else {
        await _tts.setLanguage('zh-CN'); // 退而求其次
      }

      final List<dynamic> voices = await _tts.getVoices;
      final List<Map<String, String>> castVoices = voices
          .whereType<Map>()
          .map((v) => v.map((key, value) => MapEntry('$key', '$value')))
          .toList();

      final Map<String, String>? twVoice = castVoices
          .cast<Map<String, String>?>()
          .firstWhere(
            (v) => (v?['locale'] ?? '').toLowerCase().contains('zh-tw'),
            orElse: () => null,
          );

      if (twVoice != null) {
        await _tts.setVoice({
          'name': twVoice['name']!,
          'locale': twVoice['locale']!,
        });
        // dev.log(
        //   'TimerServiceHandler::using voice: ${twVoice['name']} (${twVoice['locale']})',
        // );
      }
    } catch (e, s) {
      // dev.log('TimerServiceHandler::_initTts error: $e', stackTrace: s);
    }

    // 2. 語速/音調/音量
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    // 3. 確保語音能完整播完才回傳（配合 unawaited 呼叫不會卡住輪詢）
    await _tts.awaitSpeakCompletion(true);

    // 4. QUEUE_FLUSH：新語音進來時，系統自動平順地中斷舊語音接上新語音，避免破音
    await _tts.setQueueMode(1);
  }

  @override
  void onReceiveData(Object data) {
    if (data is! Map<String, dynamic>) return;
    final String? command = data['command'];

    switch (command) {
      case 'start':
        _config = TimerConfig.fromJson(data['config']);
        _startTraining();
        break;
      case 'togglePause':
        _togglePause();
        break;
      case 'reset':
        _reset();
        break;
      case 'applyLiveChanges':
        _applyLiveChanges(TimerConfig.fromJson(data['config']));
        break;
    }
  }

  void _startTraining() {
    _state = TimerState.initial;
    _phaseDuration = _config.prepTime;
    _phaseStartTime = DateTime.now();
    _state = _state.copyWith(timer: _config.prepTime);

    unawaited(_speak(_prepPhrase()));
    _pushState();
  }

  String _prepPhrase() =>
      '${_cn(_state.currentSet)}之${_cn(_state.currentPlayer)}預備';

  Future<void> _speak(String msg) async {
    try {
      await _tts.speak(msg);
    } catch (e, s) {
      // dev.log('TimerServiceHandler::_speak error: $e', stackTrace: s);
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (_state.isPaused || _state.isFinished || _phaseStartTime == null) return;
    _tick();
  }

  void _tick() {
    final int elapsed =
        DateTime.now().difference(_phaseStartTime!).inMilliseconds ~/ 1000;
    final int remaining = _phaseDuration - elapsed;
    final int prevTimer = _state.timer;

    if (remaining > 0) {
      _state = _state.copyWith(timer: remaining);

      if (prevTimer != remaining) {
        final bool isInitialPrep =
            _state.phase == Phase.prep &&
            _state.currentRound == 1 &&
            _state.currentSet == 1 &&
            _state.currentPlayer == 1;

        if (remaining == 6 && _state.phase == Phase.prep && !isInitialPrep) {
          unawaited(_speak(_prepPhrase()));
        } else if (remaining == 3) {
          unawaited(_speak('3'));
          Vibration.vibrate(duration: 200); 
        } else if (remaining == 2) {
          unawaited(_speak('2'));
        } else if (remaining == 1) {
          unawaited(_speak('1'));
        }
        _pushState();
        _updateNotification();
      }
    } else {
      _state = _state.copyWith(timer: 0);
      _moveToNextState();
      _pushState();
      _updateNotification();
    }
  }

  void _moveToNextState() {
    if (_state.phase == Phase.prep) {
      _state = _state.copyWith(phase: Phase.work, timer: _config.workTime);
      _phaseDuration = _config.workTime;
      _phaseStartTime = DateTime.now();
      unawaited(_speak('開始'));
    } else {
      String prompt = '換人';
      int round = _state.currentRound;
      int set = _state.currentSet;
      int player = _state.currentPlayer;

      if (player == 1) {
        player = 2;
      } else if (set < _config.setsPerRound) {
        set++;
        player = 1;
      } else if (round < _config.totalRounds) {
        round++;
        set = 1;
        player = 1;
        prompt = '下一個動作';
      } else {
        _finishTraining();
        return;
      }

      _state = _state.copyWith(
        currentRound: round,
        currentSet: set,
        currentPlayer: player,
        phase: Phase.prep,
        timer: _config.prepTime,
      );
      _phaseDuration = _config.prepTime;
      _phaseStartTime = DateTime.now();
      unawaited(_speak(prompt));
    }
  }

  void _togglePause() {
    final bool nowPaused = !_state.isPaused;
    if (nowPaused) {
      unawaited(_tts.stop());
      _phaseDuration = _state.timer; // 剩餘秒數變成新 duration
    } else {
      _phaseStartTime = DateTime.now();
    }
    _state = _state.copyWith(isPaused: nowPaused);
    _pushState();
  }

  void _finishTraining() {
    _state = _state.copyWith(isFinished: true, timer: 0);
    unawaited(_speak('訓練結束'));
    _pushState();
    _updateNotification(text: '訓練完成！');

    _finishTimer?.cancel();
    _finishTimer = Timer(const Duration(seconds: 3), () {
      FlutterForegroundTask.stopService();
    });
  }

  void _reset() {
    _finishTimer?.cancel();
    unawaited(_tts.stop());
    FlutterForegroundTask.stopService();
  }

  void _applyLiveChanges(TimerConfig newConfig) {
    final int doneUnits =
        (_state.currentRound - 1) * _config.setsPerRound * 2 +
        (_state.currentSet - 1) * 2 +
        (_state.currentPlayer - 1);
    final int newTotalUnits =
        newConfig.totalRounds * newConfig.setsPerRound * 2;

    _config = newConfig;

    if (doneUnits >= newTotalUnits) {
      _finishTraining();
      return;
    }

    if (_state.currentRound > _config.totalRounds) {
      _finishTraining();
      return;
    }

    if (_state.currentSet > _config.setsPerRound) {
      _state = _state.copyWith(
        currentSet: _config.setsPerRound,
        currentPlayer: 2,
        timer: 1,
      );
      _phaseDuration = 1;
      _phaseStartTime = DateTime.now();
    }

    _pushState();
  }

  void _pushState() {
    FlutterForegroundTask.sendDataToMain(_state.toJson());
    // dev.log('TimerServiceHandler::state: ${_state.toJson()}');
  }

  void _updateNotification({String? text}) {
    final String display =
        text ??
        '${_state.currentSet}-${_state.currentPlayer}  ${_state.timer}s';
    FlutterForegroundTask.updateService(
      notificationTitle: '教練計時器執行中',
      notificationText: display,
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _finishTimer?.cancel();
    await _tts.stop();
    Vibration.cancel();
  }
}
