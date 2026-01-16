import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/domain/usecases/generate_daily_snapshot.dart';

/// Onboarding steps
enum OnboardingStep {
  accounts,
  baseline,
  assetsLiabilities,
  timeFreedom,
  completed,
}

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

class StartOnboardingEvent extends OnboardingEvent {
  const StartOnboardingEvent();
}

class NextStepEvent extends OnboardingEvent {
  const NextStepEvent();
}

class PreviousStepEvent extends OnboardingEvent {
  const PreviousStepEvent();
}

class GoToStepEvent extends OnboardingEvent {
  final OnboardingStep step;

  const GoToStepEvent(this.step);

  @override
  List<Object?> get props => [step];
}

class CompleteOnboardingEvent extends OnboardingEvent {
  const CompleteOnboardingEvent();
}

// States
abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingInProgress extends OnboardingState {
  final OnboardingStep currentStep;
  final int stepIndex;
  final int totalSteps;

  const OnboardingInProgress({
    required this.currentStep,
    required this.stepIndex,
    required this.totalSteps,
  });

  bool get isFirstStep => stepIndex == 0;
  bool get isLastStep => stepIndex == totalSteps - 1;
  double get progress => (stepIndex + 1) / totalSteps;

  @override
  List<Object?> get props => [currentStep, stepIndex, totalSteps];
}

class OnboardingGeneratingSnapshot extends OnboardingState {
  const OnboardingGeneratingSnapshot();
}

class OnboardingComplete extends OnboardingState {
  final DailySnapshotResult snapshotResult;

  const OnboardingComplete(this.snapshotResult);

  @override
  List<Object?> get props => [snapshotResult];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GenerateDailySnapshotUseCase generateDailySnapshot;

  static const List<OnboardingStep> _steps = [
    OnboardingStep.accounts,
    OnboardingStep.baseline,
    OnboardingStep.assetsLiabilities,
    OnboardingStep.timeFreedom,
  ];

  OnboardingBloc({
    required this.generateDailySnapshot,
  }) : super(const OnboardingInitial()) {
    on<StartOnboardingEvent>(_onStart);
    on<NextStepEvent>(_onNextStep);
    on<PreviousStepEvent>(_onPreviousStep);
    on<GoToStepEvent>(_onGoToStep);
    on<CompleteOnboardingEvent>(_onComplete);
  }

  void _onStart(
    StartOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingInProgress(
      currentStep: _steps[0],
      stepIndex: 0,
      totalSteps: _steps.length,
    ));
  }

  void _onNextStep(
    NextStepEvent event,
    Emitter<OnboardingState> emit,
  ) {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    final nextIndex = currentState.stepIndex + 1;

    if (nextIndex >= _steps.length) {
      // Trigger completion
      add(const CompleteOnboardingEvent());
      return;
    }

    emit(OnboardingInProgress(
      currentStep: _steps[nextIndex],
      stepIndex: nextIndex,
      totalSteps: _steps.length,
    ));
  }

  void _onPreviousStep(
    PreviousStepEvent event,
    Emitter<OnboardingState> emit,
  ) {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    final prevIndex = currentState.stepIndex - 1;

    if (prevIndex < 0) return;

    emit(OnboardingInProgress(
      currentStep: _steps[prevIndex],
      stepIndex: prevIndex,
      totalSteps: _steps.length,
    ));
  }

  void _onGoToStep(
    GoToStepEvent event,
    Emitter<OnboardingState> emit,
  ) {
    final stepIndex = _steps.indexOf(event.step);
    if (stepIndex == -1) return;

    emit(OnboardingInProgress(
      currentStep: event.step,
      stepIndex: stepIndex,
      totalSteps: _steps.length,
    ));
  }

  Future<void> _onComplete(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingGeneratingSnapshot());

    // Generate the first daily snapshot
    final result = await generateDailySnapshot(const NoParams());

    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (snapshotResult) => emit(OnboardingComplete(snapshotResult)),
    );
  }
}
