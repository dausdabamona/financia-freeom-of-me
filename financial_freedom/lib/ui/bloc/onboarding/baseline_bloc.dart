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

class SaveBaselineEvent extends BaselineEvent {
  const SaveBaselineEvent();
}

class UpdateBaselineEvent extends BaselineEvent {
  final double housing;
  final double food;
  final double transport;
  final double health;
  final double utilities;
  final double debtPayments;
  final double other;

  const UpdateBaselineEvent({
    required this.housing,
    required this.food,
    required this.transport,
    required this.health,
    required this.utilities,
    required this.debtPayments,
    required this.other,
  });

  @override
  List<Object?> get props => [housing, food, transport, health, utilities, debtPayments, other];
}

// States
abstract class BaselineState extends Equatable {
  const BaselineState();

  // Default getters for UI consumption
  double get housing => 0;
  double get food => 0;
  double get transport => 0;
  double get health => 0;
  double get utilities => 0;
  double get debtPayments => 0;
  double get other => 0;
  double get totalBaseline => housing + food + transport + health + utilities + debtPayments + other;
  bool get isLoading => false;

  @override
  List<Object?> get props => [];
}

class BaselineInitial extends BaselineState {
  const BaselineInitial();
}

class BaselineLoading extends BaselineState {
  const BaselineLoading();

  @override
  bool get isLoading => true;
}

class BaselineEditing extends BaselineState {
  @override
  final double housing;
  @override
  final double food;
  @override
  final double transport;
  @override
  final double health;
  @override
  final double utilities;
  @override
  final double debtPayments;
  @override
  final double other;

  const BaselineEditing({
    required this.housing,
    required this.food,
    required this.transport,
    required this.health,
    required this.utilities,
    required this.debtPayments,
    required this.other,
  });

  @override
  double get totalBaseline => housing + food + transport + health + utilities + debtPayments + other;

  @override
  List<Object?> get props => [housing, food, transport, health, utilities, debtPayments, other];
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
    on<UpdateBaselineEvent>(_onUpdateBaseline);
    on<SaveBaselineEvent>(_onSaveBaselineFromState);
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

  void _onUpdateBaseline(
    UpdateBaselineEvent event,
    Emitter<BaselineState> emit,
  ) {
    emit(BaselineEditing(
      housing: event.housing,
      food: event.food,
      transport: event.transport,
      health: event.health,
      utilities: event.utilities,
      debtPayments: event.debtPayments,
      other: event.other,
    ));
  }

  Future<void> _onSaveBaselineFromState(
    SaveBaselineEvent event,
    Emitter<BaselineState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BaselineEditing) return;

    emit(const BaselineLoading());

    final result = await saveBaseline(SaveBaselineParams(
      essentialCost: currentState.housing + currentState.food + currentState.transport + currentState.health + currentState.utilities,
      optionalCost: currentState.other,
      safetyBuffer: currentState.debtPayments,
    ));

    await result.fold(
      (failure) async {
        emit(BaselineEditing(
          housing: currentState.housing,
          food: currentState.food,
          transport: currentState.transport,
          health: currentState.health,
          utilities: currentState.utilities,
          debtPayments: currentState.debtPayments,
          other: currentState.other,
        ));
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
