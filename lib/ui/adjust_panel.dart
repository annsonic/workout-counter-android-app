import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/timer_state.dart';
import '../utils/input_validators.dart';

/// 顯示中途調整面板。
/// [config] 為目前設定，[state] 為目前計時狀態（用於計算剩餘時間預覽）。
/// 回傳使用者套用後的新設定；若取消則回傳 null。
Future<TimerConfig?> showAdjustPanel({
  required BuildContext context,
  required TimerConfig config,
  required TimerState state,
}) {
  return showGeneralDialog<TimerConfig>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _AdjustPanel(config: config, state: state);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _AdjustPanel extends StatefulWidget {
  final TimerConfig config;
  final TimerState state;

  const _AdjustPanel({required this.config, required this.state});

  @override
  State<_AdjustPanel> createState() => _AdjustPanelState();
}

class _AdjustPanelState extends State<_AdjustPanel> {
  late final TextEditingController _roundsController;
  late final TextEditingController _setsController;
  late final TextEditingController _workController;

  bool _roundsError = false;
  bool _setsError = false;
  bool _workError = false;

  String _previewText = '';

  @override
  void initState() {
    super.initState();
    _roundsController = TextEditingController(
      text: '${widget.config.totalRounds}',
    );
    _setsController = TextEditingController(
      text: '${widget.config.setsPerRound}',
    );
    _workController = TextEditingController(text: '${widget.config.workTime}');
    _updatePreview();
  }

  void _updatePreview() {
    final int? r = int.tryParse(_roundsController.text);
    final int? s = int.tryParse(_setsController.text);
    final int? w = int.tryParse(_workController.text);

    if (r == null || s == null || w == null || r == 0 || s == 0 || w == 0) {
      setState(() => _previewText = '—');
      return;
    }

    final TimerState st = widget.state;
    final TimerConfig oldConfig = widget.config;

    // 已完成的 unit 數（用舊 config 計算）
    final int doneUnits =
        (st.currentRound - 1) * oldConfig.setsPerRound * 2 +
        (st.currentSet - 1) * 2 +
        (st.currentPlayer - 1);

    // 用新規格計算總 units
    final int newTotalUnits = r * s * 2;

    if (doneUnits >= newTotalUnits) {
      setState(() => _previewText = '⚠️ 目前進度已超出新設定範圍，將直接結束訓練');
      return;
    }

    // 從現在起剩餘的 units（用新規格）
    final int remainingUnitsFromNow = newTotalUnits - doneUnits;

    // 當前 phase 的剩餘秒數
    final int currentPhaseRemaining = st.timer;

    // 剩餘 units 轉換為秒數（每個 unit = PREP + WORK）
    final int fullUnitsSeconds = (remainingUnitsFromNow - 1) * (8 + w);

    final int totalRemaining = currentPhaseRemaining + fullUnitsSeconds;
    final String min = (totalRemaining / 60).toStringAsFixed(1);

    setState(() => _previewText = '套用後剩餘時間約 $min 分鐘');
  }

  void _onFieldChanged() => _updatePreview();

  void _clampField(TextEditingController controller, int min, int max) {
    controller.text = InputValidators.clamp(
      controller.text,
      min,
      max,
    ).toString();
  }

  void _apply() {
    _clampField(_roundsController, 1, 99);
    _clampField(_setsController, 1, 99);
    _clampField(_workController, 10, 9999);

    final bool roundsValid = InputValidators.isValid(
      _roundsController.text,
      1,
      99,
    );
    final bool setsValid = InputValidators.isValid(_setsController.text, 1, 99);
    final bool workValid = InputValidators.isValid(
      _workController.text,
      10,
      9999,
    );

    setState(() {
      _roundsError = !roundsValid;
      _setsError = !setsValid;
      _workError = !workValid;
    });

    if (!roundsValid || !setsValid || !workValid) return;

    final TimerConfig newConfig = TimerConfig(
      totalRounds: int.parse(_roundsController.text),
      setsPerRound: int.parse(_setsController.text),
      workTime: int.parse(_workController.text),
      prepTime: widget.config.prepTime,
    );

    Navigator.of(context).pop(newConfig);
  }

  void _cancel() {
    Navigator.of(context).pop(null);
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
                    '中途調整',
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
                    min: 1,
                    max: 99,
                  ),
                  const SizedBox(height: 16),
                  _buildInputRow(
                    label: '單人循環 (Sets)',
                    controller: _setsController,
                    hasError: _setsError,
                    errorText: '請輸入 1 ~ 99 的整數',
                    min: 1,
                    max: 99,
                  ),
                  const SizedBox(height: 16),
                  _buildInputRow(
                    label: '運動時間 (秒)',
                    controller: _workController,
                    hasError: _workError,
                    errorText: '請輸入 10 ~ 9999 的整數',
                    min: 10,
                    max: 9999,
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
                      _previewText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFB0B0B5), // --color-label
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFA05050,
                            ).withValues(alpha: 0.3),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            '取消',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6880),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            '套用',
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
    required int min,
    required int max,
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
                  if (!hasFocus) {
                    setState(() {
                      _clampField(controller, min, max);
                      if (identical(controller, _roundsController)) {
                        _roundsError = false;
                      } else if (identical(controller, _setsController)) {
                        _setsError = false;
                      } else if (identical(controller, _workController)) {
                        _workError = false;
                      }
                    });
                    _updatePreview();
                  }
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
                  onChanged: (value) {
                    setState(() {
                      final bool valid = InputValidators.isValid(
                        value,
                        min,
                        max,
                      );
                      if (identical(controller, _roundsController)) {
                        _roundsError = !valid;
                      } else if (identical(controller, _setsController)) {
                        _setsError = !valid;
                      } else if (identical(controller, _workController)) {
                        _workError = !valid;
                      }
                    });
                    _onFieldChanged();
                  },
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
