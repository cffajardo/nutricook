import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';

class RecipeViewInstructions extends StatefulWidget {
  final List<RecipeStep> steps;
  final int startCookingSignal;

  const RecipeViewInstructions({
    super.key,
    required this.steps,
    this.startCookingSignal = 0,
  });

  @override
  State<RecipeViewInstructions> createState() => _RecipeViewInstructionsState();
}

class _RecipeViewInstructionsState extends State<RecipeViewInstructions> {
  static const int _autoAdvanceSecondsForUntimedStep = 8;

  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  List<GlobalKey> _stepKeys = <GlobalKey>[];

  bool _isCookingSessionActive = false;
  bool _isUsingAutoAdvanceTimer = false;
  int _activeStepIndex = 0;
  int _remainingSeconds = 0;
  int _originalStepDuration = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _syncStepKeys();
  }

  @override
  void didUpdateWidget(covariant RecipeViewInstructions oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.steps.length != widget.steps.length) {
      _syncStepKeys();
      if (widget.steps.isEmpty) {
        _timer?.cancel();
        _isCookingSessionActive = false;
        _isUsingAutoAdvanceTimer = false;
        _activeStepIndex = 0;
        _remainingSeconds = 0;
        _isTimerRunning = false;
      } else if (_activeStepIndex >= widget.steps.length) {
        _activeStepIndex = widget.steps.length - 1;
      }
    }

    if (oldWidget.startCookingSignal != widget.startCookingSignal) {
      _startCookingFromFab();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncStepKeys() {
    _stepKeys = List<GlobalKey>.generate(
      widget.steps.length,
      (_) => GlobalKey(),
    );
  }

  void _startCookingFromFab() {
    if (widget.steps.isEmpty) return;

    _activateStep(0, activateSession: true, startTimer: true);
  }

  void _scrollToActiveStep() {
    if (_activeStepIndex < 0 || _activeStepIndex >= _stepKeys.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetContext = _stepKeys[_activeStepIndex].currentContext;
      if (targetContext == null) return;

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.12,
      );
    });
  }

  void _activateStep(
    int index, {
    bool activateSession = true,
    bool startTimer = true,
  }) {
    if (widget.steps.isEmpty || index < 0 || index >= widget.steps.length) {
      return;
    }

    _timer?.cancel();
    setState(() {
      _activeStepIndex = index;
      _originalStepDuration = 0;
      _remainingSeconds = 0;
      _isTimerRunning = false;
      _isUsingAutoAdvanceTimer = false;
      if (activateSession) {
        _isCookingSessionActive = true;
      }
    });

    _scrollToActiveStep();
    if (startTimer) {
      _startTimerForActiveStep();
    }
  }

  void _startTimerForActiveStep() {
    if (!_isCookingSessionActive) return;
    _timer?.cancel();
    if (widget.steps.isEmpty) return;

    final currentStep = widget.steps[_activeStepIndex];
    final usesAutoAdvance = currentStep.timerSeconds <= 0;
    final stepDurationSeconds = usesAutoAdvance
        ? _autoAdvanceSecondsForUntimedStep
        : currentStep.timerSeconds;

    setState(() {
      _originalStepDuration = stepDurationSeconds;
      _remainingSeconds = stepDurationSeconds;
      _isTimerRunning = true;
      _isUsingAutoAdvanceTimer = usesAutoAdvance;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds -= 1);
        return;
      }

      timer.cancel();
      setState(() {
        _remainingSeconds = 0;
        _isTimerRunning = false;
        _isUsingAutoAdvanceTimer = false;
      });
      _goToNextStep(fromTimerCompletion: true);
    });
  }

  void _pauseTimer() {
    if (!_isCookingSessionActive) return;
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resumeTimer() {
    if (!_isCookingSessionActive) return;
    if (_remainingSeconds <= 0 || _isTimerRunning) return;

    setState(() => _isTimerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds -= 1);
        return;
      }

      timer.cancel();
      setState(() {
        _remainingSeconds = 0;
        _isTimerRunning = false;
        _isUsingAutoAdvanceTimer = false;
      });
      _goToNextStep(fromTimerCompletion: true);
    });
  }

  void _resetTimer() {
    if (!_isCookingSessionActive || _originalStepDuration <= 0) return;
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _originalStepDuration;
      _isTimerRunning = false;
    });
  }

  void _goToNextStep({bool fromTimerCompletion = false}) {
    if (!_isCookingSessionActive || widget.steps.isEmpty) return;

    if (_activeStepIndex >= widget.steps.length - 1) {
      _timer?.cancel();
      setState(() {
        _isTimerRunning = false;
        _remainingSeconds = 0;
        _isUsingAutoAdvanceTimer = false;
      });
      if (fromTimerCompletion) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All cooking steps complete.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    _activateStep(
      _activeStepIndex + 1,
      activateSession: true,
      startTimer: true,
    );
  }

  void _goToPreviousStep() {
    if (!_isCookingSessionActive ||
        widget.steps.isEmpty ||
        _activeStepIndex <= 0) {
      return;
    }

    _activateStep(
      _activeStepIndex - 1,
      activateSession: true,
      startTimer: true,
    );
  }

  String _formatSeconds(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isCookingSessionActive && widget.steps.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.cardRose.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.rosePink.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${_activeStepIndex + 1} of ${widget.steps.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.rosePink,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_activeStepIndex + 1) / widget.steps.length,
                  minHeight: 6,
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.rosePink,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            itemCount: widget.steps.length,
            itemBuilder: (context, index) {
              final step = widget.steps[index];
              final int timerSeconds = step.timerSeconds;
              final isActive =
                  _isCookingSessionActive && index == _activeStepIndex;
              final showLiveTimer = isActive && _remainingSeconds > 0;

              return InkWell(
                onTap: () => _activateStep(
                  index,
                  activateSession: true,
                  startTimer: true,
                ),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  key: _stepKeys.isNotEmpty ? _stepKeys[index] : null,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isActive ? AppColors.rosePink : Colors.black,
                      width: isActive ? 2 : 1.5,
                    ),
                    color: isActive
                        ? AppColors.cardRose.withValues(alpha: 0.22)
                        : Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.rosePink,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.instruction,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Current Step',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.rosePink,
                                ),
                              ),
                            ],

                            if (showLiveTimer) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.rosePink.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isUsingAutoAdvanceTimer
                                          ? Icons.auto_mode_rounded
                                          : Icons.timelapse_rounded,
                                      size: 16,
                                      color: AppColors.rosePink,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatSeconds(_remainingSeconds),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.rosePink,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: _isTimerRunning
                                          ? _pauseTimer
                                          : _resumeTimer,
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.rosePink.withValues(
                                            alpha: 0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isTimerRunning
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 16,
                                          color: AppColors.rosePink,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: _resetTimer,
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.rosePink.withValues(
                                            alpha: 0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.refresh_rounded,
                                          size: 16,
                                          color: AppColors.rosePink,
                                        ),
                                      ),
                                    ),
                                    if (_isUsingAutoAdvanceTimer) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardRose.withValues(
                                            alpha: 0.35,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: const Text(
                                          'AUTO',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.rosePink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ] else if (timerSeconds > 0) ...[
                              const SizedBox(height: 12),
                              _buildTimerChip(timerSeconds),
                            ],

                            if (isActive) ...[
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _activeStepIndex > 0
                                        ? _goToPreviousStep
                                        : null,
                                    icon: const Icon(
                                      Icons.chevron_left_rounded,
                                      size: 18,
                                    ),
                                    label: const Text('Back'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.rosePink,
                                      side: BorderSide(
                                        color: AppColors.rosePink.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed:
                                        _activeStepIndex <
                                            widget.steps.length - 1
                                        ? _goToNextStep
                                        : null,
                                    icon: const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                    ),
                                    label: const Text('Next'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.rosePink,
                                      side: BorderSide(
                                        color: AppColors.rosePink.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerChip(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;

    String timeStr = '';
    if (h > 0) timeStr += '${h}h ';
    if (m > 0) timeStr += '${m}m ';
    if (s > 0 || timeStr.isEmpty) timeStr += '${s}s';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardRose.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: AppColors.rosePink),
          const SizedBox(width: 6),
          Text(
            timeStr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.rosePink,
            ),
          ),
        ],
      ),
    );
  }
}
