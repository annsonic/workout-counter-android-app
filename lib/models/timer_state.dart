enum Phase { prep, work }

class TimerConfig {
  const TimerConfig({
    required this.totalRounds,
    required this.setsPerRound,
    required this.workTime,
    this.prepTime = 8,
  });

  final int totalRounds;
  final int setsPerRound;
  final int workTime;
  final int prepTime;

  TimerConfig copyWith({int? totalRounds, int? setsPerRound, int? workTime}) {
    return TimerConfig(
      totalRounds: totalRounds ?? this.totalRounds,
      setsPerRound: setsPerRound ?? this.setsPerRound,
      workTime: workTime ?? this.workTime,
      prepTime: prepTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalRounds': totalRounds,
    'setsPerRound': setsPerRound,
    'workTime': workTime,
    'prepTime': prepTime,
  };

  factory TimerConfig.fromJson(Map<String, dynamic> json) => TimerConfig(
    totalRounds: json['totalRounds'],
    setsPerRound: json['setsPerRound'],
    workTime: json['workTime'],
    prepTime: json['prepTime'] ?? 8,
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
