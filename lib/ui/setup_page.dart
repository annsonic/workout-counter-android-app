import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/timer_state.dart';
import '../utils/input_validators.dart';
import 'timer_page.dart';

const int kPrepTime = 8;

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController _roundsController = TextEditingController(
    text: '5',
  );
  final TextEditingController _setsController = TextEditingController(
    text: '2',
  );
  final TextEditingController _workController = TextEditingController(
    text: '40',
  );

  bool _roundsError = false;
  bool _setsError = false;
  bool _workError = false;

  String _totalTimeLabel = '';

  @override
  void initState() {
    super.initState();
    _updateTotalTime();
  }

  void _onRoundsChanged(String value) {
    setState(() {
      _roundsError = !InputValidators.isValid(value, 1, 99);
    });
    _updateTotalTime();
  }

  void _onSetsChanged(String value) {
    setState(() {
      _setsError = !InputValidators.isValid(value, 1, 99);
    });
    _updateTotalTime();
  }

  void _onWorkChanged(String value) {
    setState(() {
      _workError = !InputValidators.isValid(value, 10, 9999);
    });
    _updateTotalTime();
  }

  void _clampAll() {
    final int rounds = InputValidators.clamp(_roundsController.text, 1, 99);
    final int sets = InputValidators.clamp(_setsController.text, 1, 99);
    final int work = InputValidators.clamp(_workController.text, 10, 9999);

    setState(() {
      _roundsController.text = '$rounds';
      _setsController.text = '$sets';
      _workController.text = '$work';
      _roundsError = false;
      _setsError = false;
      _workError = false;
    });
  }

  void _updateTotalTime() {
    final int? rounds = int.tryParse(_roundsController.text);
    final int? sets = int.tryParse(_setsController.text);
    final int? workTime = int.tryParse(_workController.text);

    if (rounds == null ||
        sets == null ||
        workTime == null ||
        rounds == 0 ||
        sets == 0 ||
        workTime == 0) {
      setState(() => _totalTimeLabel = '總訓練時間：—');
      return;
    }

    final int totalSeconds = (kPrepTime + workTime) * 2 * sets * rounds;
    setState(() {
      if (totalSeconds <= 60) {
        _totalTimeLabel = '總訓練時間：約 $totalSeconds 秒';
      } else {
        final String minutes = (totalSeconds / 60).toStringAsFixed(1);
        _totalTimeLabel = '總訓練時間：約 $minutes 分鐘';
      }
    });
  }

  void _startApp() {
    _clampAll();

    final int rounds = int.parse(_roundsController.text);
    final int sets = int.parse(_setsController.text);
    final int work = int.parse(_workController.text);

    final TimerConfig config = TimerConfig(
      totalRounds: rounds,
      setsPerRound: sets,
      workTime: work,
      prepTime: kPrepTime,
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TimerPage(config: config)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // --bg-base
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2D), // --bg-card
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '訓練參數設定',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7A9BB5), // --color-accent
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInputRow(
                    label: '動作項目 (Rounds)',
                    controller: _roundsController,
                    hasError: _roundsError,
                    errorText: '請輸入 1 ~ 99 的整數',
                    onChanged: _onRoundsChanged,
                    onBlurClamp: () {
                      setState(() {
                        _roundsController.text = InputValidators.clamp(
                          _roundsController.text,
                          1,
                          99,
                        ).toString();
                        _roundsError = false;
                      });
                      _updateTotalTime();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputRow(
                    label: '單人循環 (Sets)',
                    controller: _setsController,
                    hasError: _setsError,
                    errorText: '請輸入 1 ~ 99 的整數',
                    onChanged: _onSetsChanged,
                    onBlurClamp: () {
                      setState(() {
                        _setsController.text = InputValidators.clamp(
                          _setsController.text,
                          1,
                          99,
                        ).toString();
                        _setsError = false;
                      });
                      _updateTotalTime();
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputRow(
                    label: '運動時間 (秒)',
                    controller: _workController,
                    hasError: _workError,
                    errorText: '請輸入 10 ~ 9999 的整數',
                    onChanged: _onWorkChanged,
                    onBlurClamp: () {
                      setState(() {
                        _workController.text = InputValidators.clamp(
                          _workController.text,
                          10,
                          9999,
                        ).toString();
                        _workError = false;
                      });
                      _updateTotalTime();
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _totalTimeLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB0B0B5), // --color-label
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_roundsError || _setsError || _workError)
                          ? null
                          : _startApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF4A6880,
                        ), // --btn-primary
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        '開始訓練',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
    required bool hasError,
    required String errorText,
    required ValueChanged<String> onChanged,
    required VoidCallback onBlurClamp,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF8A8A8E), // --color-muted
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 7,
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) onBlurClamp();
                },
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE0E0E0),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF3A3A3E), // --bg-input
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: hasError
                          ? const BorderSide(color: Color(0xFFA06060), width: 2)
                          : BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: hasError
                            ? const Color(0xFFA06060)
                            : const Color(0xFF7A9BB5),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Expanded(flex: 5, child: SizedBox()),
                const SizedBox(width: 12),
                Expanded(
                  flex: 7,
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Color(0xFFC08080),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _roundsController.dispose();
    _setsController.dispose();
    _workController.dispose();
    super.dispose();
  }
}
