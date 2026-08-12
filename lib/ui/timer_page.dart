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
    if (phase == Phase.work) return const Color(0xFF4A6B5A);
    if (phase == Phase.prep) return const Color(0xFF7A5C4A);
    return const Color(0xFF1C1C1E);
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
                Expanded(child: Center(child: _buildCenter(state))),
                _buildControls(state),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '項目 ${state.currentRound}/${widget.config.totalRounds}',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(widget.config.totalRounds, (i) {
              final idx = i + 1;
              double percent = 0;
              double opacity = 1;
              if (idx < state.currentRound) {
                percent = 1;
                opacity = 0.35;
              } else if (idx == state.currentRound) {
                final totalUnits = widget.config.setsPerRound * 2;
                final completed =
                    ((state.currentSet - 1) * 2) + (state.currentPlayer - 1);
                percent = completed / totalUnits;
              }
              return Expanded(
                child: Container(
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: state.isFinished ? 1 : percent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: opacity * 0.7),
                        borderRadius: BorderRadius.circular(6),
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
    if (state == null) return const CircularProgressIndicator();
    if (state.isFinished) {
      return const Text(
        'DONE',
        style: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      );
    }
    return Column(
      children: [
        Text(
          '${state.currentSet}-${state.currentPlayer}',
          style: const TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pill('第 ${state.currentSet} 遍'),
            const SizedBox(width: 24),
            Text(
              state.timer.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 24),
            _pill(state.phase == Phase.prep ? '預備 PREP' : '運動 WORK'),
          ],
        ),
      ],
    );
  }

  Widget _pill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildControls(TimerState? state) {
    final bool canAdjust =
        state != null && !state.isFinished && state.phase == Phase.prep;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.replay, color: Colors.white),
            onPressed: () {
              _controller.resetApp();
              Navigator.of(context).pop();
            },
          ),
          FloatingActionButton(
            onPressed: _controller.togglePause,
            child: Icon(
              state?.isPaused == true ? Icons.play_arrow : Icons.pause,
            ),
          ),
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: canAdjust ? () => _openAdjustPanel(state) : null,
          ),
        ],
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
