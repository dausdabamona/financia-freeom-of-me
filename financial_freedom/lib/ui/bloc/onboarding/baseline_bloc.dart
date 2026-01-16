import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/monthly_baseline.dart';
import 'package:financial_freedom/domain/usecases/save_baseline.dart';
import 'package:financial_freedom/domain/repositories/monthly_baseline_repository.dart';

// Events
abstract class BaselineEvent extends Equatable {
  const BaselineEvent();
  @override
  List<Object?> get props => [];
}

class LoadBaselineEvent extends BaselineEvent {
  const LoadBaselineEvent();
}

class SaveBaselineDataEvent extends BaselineEvent {
  final double essentialCost;
  final double optionalCost;
  final double safetyBuffer;
  final String? notes;

  const SaveBaselineDataEvent({
    required this.essentialCost,
    required this.optionalCost,
    required this.safetyBuffer,
    this.notes,
  });

  @override
  List<Object?> get props => [essentialCost, optionalCost, safetyBuffer, notes];
}

class FinishBaselineSetupEvent extends BaselineEvent {
  const FinishBaselineSetupEvent();
}

// States
abstract class BaselineState extends Equatable {
  const BaselineState();
  @override
  List<Object?> get props => [];
}

class BaselineInitial extends BaselineState {
  const BaselineInitial();
}

class BaselineLoading extends BaselineState {
  const BaselineLoading();
}

class BaselineReady extends BaselineState {
  final MonthlyBaseline? baseline;
  final String? message;

  const BaselineReady({
    this.baseline,
    this.message,
  });

  double get totalBaseline => baseline?.totalBaseline ?? 0;

  @override
  List<Object?> get props => [baseline, message];
}

class BaselineError extends BaselineState {
  final String message;

  const BaselineError(this.message);

  @override
  List<Object?> get props => [message];
}

class BaselineCompleted extends BaselineState {
  final MonthlyBaseline? baseline;

  const BaselineCompleted(this.baseline);

  @override
  List<Object?> get props => [baseline];
}

// BLoC
class BaselineBloc extends Bloc<BaselineEvent, BaselineState> {
  final SaveBaseline saveBaseline;
  final MonthlyBaselineRepository baselineRepository;

  BaselineBloc({
    required this.saveBaseline,
    required this.baselineRepository,
  }) : super(const BaselineInitial()) {
    on<LoadBaselineEvent>(_onLoadBaseline);
    on<SaveBaselineDataEvent>(_onSaveBaseline);
    on<FinishBaselineSetupEvent>(_onFinishSetup);
  }

  Future<void> _onLoadBaseline(
    LoadBaselineEvent event,
    Emitter<BaselineState> emit,
  ) async {
    emit(const BaselineLoading());

    final result = await baselineRepository.getLatestBaseline();
    result.fold(
      (failure) => emit(BaselineError(failure.message)),
      (baseline) => emit(BaselineReady(baseline: baseline)),
    );
  }

  Future<void> _onSaveBaseline(
    SaveBaselineDataEvent event,
    Emitter<BaselineState> emit,
  ) async {
    emit(const BaselineLoading());

    final result = await saveBaseline(SaveBaselineParams(
      essentialCost: event.essentialCost,
      optionalCost: event.optionalCost,
      safetyBuffer: event.safetyBuffer,
      notes: event.notes,
    ));

    await result.fold(
      (failure) async {
        emit(BaselineReady(message: failure.message));
      },
      (_) async {
        final baselineResult = await baselineRepository.getLatestBaseline();
        baselineResult.fold(
          (failure) => emit(BaselineError(failure.message)),
          (baseline) => emit(BaselineReady(
            baseline: baseline,
            message: 'Baseline berhasil disimpan',
          )),
        );
      },
    );
  }

  Future<void> _onFinishSetup(
    FinishBaselineSetupEvent event,
    Emitter<BaselineState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BaselineReady) return;

    emit(BaselineCompleted(currentState.baseline));
  }
}
