enum Phase { prep, work }

class TimerConfig {
  const TimerConfig({
    required this.totalRounds,
    required this.setsPerRound,
    required this.workTime,
    this.initialPrepTime = 8,
    this.switchPlayerPrepTime = 20,
    this.switchStationPrepTime = 25,
  });

  final int totalRounds;
  final int setsPerRound;
  final int workTime;

  // 訓練最開始（round==1 && set==1 && player==1）的準備時間。
  // 學員已就位，等教練按下開始鍵
  final int initialPrepTime;

  // 同一個 round 內換人 / 換 set 的準備時間（同器材）
  final int switchPlayerPrepTime;

  // 換 round（換動作 / 換器材）的準備時間
  final int switchStationPrepTime;

  /// 預設設定值，作為整個 App 的唯一真相來源（Single Source of Truth）。
  /// 任何頁面需要預設的 Rounds/Sets/WorkTime 或三個準備秒數時，
  /// 都應該引用這裡，而不是各自定義常數。
  static const TimerConfig defaultTimerConfig = TimerConfig(
    totalRounds: 5,
    setsPerRound: 2,
    workTime: 40,
  );

  TimerConfig copyWith({
    int? totalRounds,
    int? setsPerRound,
    int? workTime,
    int? initialPrepTime,
    int? switchPlayerPrepTime,
    int? switchStationPrepTime,
  }) {
    return TimerConfig(
      totalRounds: totalRounds ?? this.totalRounds,
      setsPerRound: setsPerRound ?? this.setsPerRound,
      workTime: workTime ?? this.workTime,
      initialPrepTime: initialPrepTime ?? this.initialPrepTime,
      switchPlayerPrepTime: switchPlayerPrepTime ?? this.switchPlayerPrepTime,
      switchStationPrepTime:
          switchStationPrepTime ?? this.switchStationPrepTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalRounds': totalRounds,
    'setsPerRound': setsPerRound,
    'workTime': workTime,
    'initialPrepTime': initialPrepTime,
    'switchPlayerPrepTime': switchPlayerPrepTime,
    'switchStationPrepTime': switchStationPrepTime,
  };

  factory TimerConfig.fromJson(Map<String, dynamic> json) => TimerConfig(
    totalRounds: json['totalRounds'],
    setsPerRound: json['setsPerRound'],
    workTime: json['workTime'],
    initialPrepTime:
        json['initialPrepTime'] ?? defaultTimerConfig.initialPrepTime,
    switchPlayerPrepTime:
        json['switchPlayerPrepTime'] ?? defaultTimerConfig.switchPlayerPrepTime,
    switchStationPrepTime:
        json['switchStationPrepTime'] ??
        defaultTimerConfig.switchStationPrepTime,
  );
}

class TimerState {
  const TimerState({
    required this.currentRound,
    required this.currentSet,
    required this.currentPlayer,
    required this.phase,
    required this.timer,
    required this.isPaused,
    required this.isFinished,
  });

  final int currentRound;
  final int currentSet;
  final int currentPlayer;
  final Phase phase;
  final int timer;
  final bool isPaused;
  final bool isFinished;

  static const initial = TimerState(
    currentRound: 1,
    currentSet: 1,
    currentPlayer: 1,
    phase: Phase.prep,
    timer: 0,
    isPaused: false,
    isFinished: false,
  );

  TimerState copyWith({
    int? currentRound,
    int? currentSet,
    int? currentPlayer,
    Phase? phase,
    int? timer,
    bool? isPaused,
    bool? isFinished,
  }) {
    return TimerState(
      currentRound: currentRound ?? this.currentRound,
      currentSet: currentSet ?? this.currentSet,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      phase: phase ?? this.phase,
      timer: timer ?? this.timer,
      isPaused: isPaused ?? this.isPaused,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  static bool containsData(Map<String, dynamic> json) =>
      json.containsKey('currentRound') && json.containsKey('phase');

  Map<String, dynamic> toJson() => {
    'currentRound': currentRound,
    'currentSet': currentSet,
    'currentPlayer': currentPlayer,
    'phase': phase.name,
    'timer': timer,
    'isPaused': isPaused,
    'isFinished': isFinished,
  };

  factory TimerState.fromJson(Map<String, dynamic> json) => TimerState(
    currentRound: json['currentRound'],
    currentSet: json['currentSet'],
    currentPlayer: json['currentPlayer'],
    phase: json['phase'] == 'work' ? Phase.work : Phase.prep,
    timer: json['timer'],
    isPaused: json['isPaused'],
    isFinished: json['isFinished'],
  );
}
