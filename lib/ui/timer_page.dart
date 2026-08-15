import 'dart:ui';

import 'package:flutter/material.dart';

import '../controllers/timer_page_controller.dart';
import '../models/timer_state.dart';
import 'adjust_panel.dart';

class TimerPage extends StatefulWidget {
  final TimerConfig config;
  const TimerPage({super.key, required this.config});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final TimerPageController _controller = TimerPageController();

  @override
  void initState() {
    super.initState();
    _controller.attach(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.startTraining(widget.config);
    });
  }

  Color _bgColor(Phase? phase) {
    if (phase == Phase.work) return const Color(0xFF2E4039); // muted sage
    if (phase == Phase.prep) return const Color(0xFF3D2E28); // muted terracotta
    return const Color(0xFF18181B);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TimerState?>(
      valueListenable: _controller.stateListenable,
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: _bgColor(state?.phase),
          body: SafeArea(
            child: Column(
              children: [
                _buildProgress(state),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCenter(state),
                      const SizedBox(height: 32),
                      _buildControls(state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgress(TimerState? state) {
    if (state == null) return const SizedBox(height: 20);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '項目 ${state.currentRound} / ${widget.config.totalRounds}',
                style: const TextStyle(
                  color: Color(0xFF9A9690),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Sets ${widget.config.setsPerRound}',
                style: const TextStyle(
                  color: Color(0xFF6A6660),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(widget.config.totalRounds, (i) {
              final idx = i + 1;
              double percent = 0;
              double opacity = 1;
              if (idx < state.currentRound) {
                percent = 1;
                opacity = 0.3;
              } else if (idx == state.currentRound) {
                final totalUnits = widget.config.setsPerRound * 2;
                final completed =
                    ((state.currentSet - 1) * 2) + (state.currentPlayer - 1);
                percent = completed / totalUnits;
              }
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: state.isFinished ? 1 : percent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: opacity * 0.55),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCenter(TimerState? state) {
    if (state == null) return const CircularProgressIndicator(color: Color(0xFF6B8FA8));
    if (state.isFinished) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DONE',
            style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w900,
              color: Color(0xFFDDD9D4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '訓練完成',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.4),
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 主顯示：回合-選手，教練最需要看的資訊
        Text(
          '${state.currentSet}-${state.currentPlayer}',
          style: const TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w900,
            color: Color(0xFFEEEAE5),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'SET · PLAYER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        _phaseChip(state.phase == Phase.prep ? 'PREP' : 'WORK', state.phase),
        const SizedBox(height: 14),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: state.timer <= 3
                ? const Color(0xFFE8A898)
                : const Color(0xFFDDD9D4),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          child: Text(state.timer.toString().padLeft(2, '0')),
        ),
      ],
    );
  }

  Widget _phaseChip(String label, Phase phase) {
    final Color chipColor = phase == Phase.work
        ? const Color(0xFF4A7060) // sage
        : const Color(0xFF6A4E44); // terracotta
    final Color textColor = phase == Phase.work
        ? const Color(0xFF9EDBC4)
        : const Color(0xFFE8A898);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.85), width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildControls(TimerState? state) {
    final bool isFinished = state?.isFinished == true;
    final bool canAdjust =
        state != null && !isFinished && state.phase == Phase.prep;
    final bool isPaused = state?.isPaused == true;

    void resetAndPop() {
      _controller.resetApp();
      Navigator.of(context).pop();
    }

    Future<void> confirmReset() async {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E21),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '結束訓練？',
                  style: TextStyle(
                    color: Color(0xFFEEEAE5),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '目前進度將全部清除。',
                  style: TextStyle(
                    color: Color(0xFF9A9690),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(false),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '繼續訓練',
                              style: TextStyle(
                                color: Color(0xFF9A9690),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(true),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5C2E2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8A4848),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '結束訓練',
                              style: TextStyle(
                                color: Color(0xFFE8A898),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
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
      );
      if (confirmed == true) resetAndPop();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFinished)
            GestureDetector(
              onTap: resetAndPop,
              child: Container(
                width: double.infinity,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6A5A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '重新開始',
                    style: TextStyle(
                      color: Color(0xFFDDD9D4),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            )
          else ...[
            // 暫停 / 播放：全寬大按鈕，教練最頻繁操作
            GestureDetector(
              onTap: _controller.togglePause,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                height: 88,
                decoration: BoxDecoration(
                  color: isPaused
                      ? const Color(0xFF4A6A5A) // sage — resume
                      : const Color(0xFF3A3A3E), // neutral — pause
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isPaused ? 0.12 : 0.06),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: const Color(0xFFDDD9D4),
                    size: 52,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // 重置 / 調整：次要操作，縮小降低誤觸風險
            Row(
              children: [
                Expanded(
                  child: _secondaryButton(
                    icon: Icons.replay_rounded,
                    label: '重置',
                    onPressed: confirmReset,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _secondaryButton(
                        icon: Icons.tune_rounded,
                        label: '調整',
                        enabled: canAdjust,
                        onPressed: canAdjust ? () => _openAdjustPanel(state!) : null,
                      ),
                      if (!canAdjust && state != null && !isFinished)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            '僅在準備期可調整',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _secondaryButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool enabled = true,
  }) {
    final Color fg = enabled
        ? const Color(0xFF9A9690)
        : const Color(0xFF3E3E42);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: enabled ? 0.05 : 0.02),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAdjustPanel(TimerState state) async {
    final TimerConfig? newConfig = await showAdjustPanel(
      context: context,
      config: _controller.config,
      state: state,
    );

    if (newConfig != null) {
      _controller.applyLiveChanges(newConfig);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
