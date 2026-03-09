import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/recipe_step/recipe_step.dart';

class RecipeStepTimerState {
  const RecipeStepTimerState({
    required this.recipe,
    required this.currentStepIndex,
    required this.remainingSeconds,
    required this.isRunning,
    required this.isCompleted,
  });

  final Recipe recipe;
  final int currentStepIndex;
  final int remainingSeconds;
  final bool isRunning;
  final bool isCompleted;

  RecipeStep get currentStep => recipe.steps[currentStepIndex];

  bool get hasNextStep => currentStepIndex < recipe.steps.length - 1;

  RecipeStepTimerState copyWith({
    Recipe? recipe,
    int? currentStepIndex,
    int? remainingSeconds,
    bool? isRunning,
    bool? isCompleted,
  }) {
    return RecipeStepTimerState(
      recipe: recipe ?? this.recipe,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static RecipeStepTimerState initial(Recipe recipe) {
    final firstStepSeconds = recipe.steps.isEmpty
        ? 0
        : recipe.steps.first.timerSeconds;

    return RecipeStepTimerState(
      recipe: recipe,
      currentStepIndex: 0,
      remainingSeconds: firstStepSeconds,
      isRunning: false,
      isCompleted: recipe.steps.isEmpty,
    );
  }
}

class RecipeStepTimerController extends Notifier<RecipeStepTimerState> {
  RecipeStepTimerController(this.recipe);

  final Recipe recipe;

  @override
  RecipeStepTimerState build() {
    ref.onDispose(_stopTicker);
    return RecipeStepTimerState.initial(recipe);
  }

  Timer? _ticker;

  void start() {
    if (state.recipe.steps.isEmpty || state.isCompleted) {
      return;
    }

    _startTicker();
  }

  void pause() {
    _stopTicker();
    state = state.copyWith(isRunning: false);
  }

  void resetCurrentStep() {
    final currentSeconds = state.currentStep.timerSeconds;
    pause();
    state = state.copyWith(
      remainingSeconds: currentSeconds,
      isCompleted: false,
    );
  }

  void nextStep({bool autoStart = true}) {
    if (!state.hasNextStep) {
      pause();
      state = state.copyWith(isCompleted: true, remainingSeconds: 0);
      return;
    }

    pause();
    final nextIndex = state.currentStepIndex + 1;
    final nextSeconds = state.recipe.steps[nextIndex].timerSeconds;
    state = state.copyWith(
      currentStepIndex: nextIndex,
      remainingSeconds: nextSeconds,
      isCompleted: false,
    );

    if (autoStart && nextSeconds > 0) {
      _startTicker();
    }
  }

  void previousStep() {
    if (state.currentStepIndex == 0) {
      return;
    }

    pause();
    final previousIndex = state.currentStepIndex - 1;
    final previousSeconds = state.recipe.steps[previousIndex].timerSeconds;
    state = state.copyWith(
      currentStepIndex: previousIndex,
      remainingSeconds: previousSeconds,
      isCompleted: false,
    );
  }

  void seekToStep(int stepIndex, {bool autoStart = false}) {
    if (stepIndex < 0 || stepIndex >= state.recipe.steps.length) {
      return;
    }

    pause();
    final seconds = state.recipe.steps[stepIndex].timerSeconds;
    state = state.copyWith(
      currentStepIndex: stepIndex,
      remainingSeconds: seconds,
      isCompleted: false,
    );

    if (autoStart && seconds > 0) {
      _startTicker();
    }
  }

  void _startTicker() {
    _stopTicker();

    if (state.remainingSeconds <= 0) {
      _handleStepExpired();
      return;
    }

    state = state.copyWith(isRunning: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _handleStepExpired();
        return;
      }

      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    });
  }

  void _handleStepExpired() {
    _stopTicker();

    if (state.hasNextStep) {
      nextStep(autoStart: true);
      return;
    }

    state = state.copyWith(
      remainingSeconds: 0,
      isRunning: false,
      isCompleted: true,
    );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

final recipeStepTimerProvider = NotifierProvider.autoDispose
    .family<RecipeStepTimerController, RecipeStepTimerState, Recipe>(
      RecipeStepTimerController.new,
    );
