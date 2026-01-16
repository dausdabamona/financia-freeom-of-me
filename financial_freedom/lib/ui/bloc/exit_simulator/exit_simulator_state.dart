part of 'exit_simulator_bloc.dart';

/// States for Exit Simulator BLoC
abstract class ExitSimulatorState extends Equatable {
  const ExitSimulatorState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ExitSimulatorInitial extends ExitSimulatorState {
  const ExitSimulatorInitial();
}

/// Loading state
class ExitSimulatorLoading extends ExitSimulatorState {
  const ExitSimulatorLoading();
}

/// Ready state - can start simulation
class ExitSimulatorReady extends ExitSimulatorState {
  final bool hasExistingSimulation;

  const ExitSimulatorReady({
    this.hasExistingSimulation = false,
  });

  @override
  List<Object?> get props => [hasExistingSimulation];
}

/// Simulation is running
class ExitSimulatorRunning extends ExitSimulatorState {
  const ExitSimulatorRunning();
}

/// Empty state - no financial data
class ExitSimulatorEmpty extends ExitSimulatorState {
  final String message;

  const ExitSimulatorEmpty({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Loaded state with results
class ExitSimulatorLoaded extends ExitSimulatorState {
  final List<ExitSimulationResult> results;
  final ExitSimulationResult selectedResult;
  final SimulationComparison? bestComparison;
  final double liquidCash;
  final double monthlyBurnRate;
  final double monthlyPassiveIncome;

  const ExitSimulatorLoaded({
    required this.results,
    required this.selectedResult,
    this.bestComparison,
    required this.liquidCash,
    required this.monthlyBurnRate,
    required this.monthlyPassiveIncome,
  });

  /// Get baseline result
  ExitSimulationResult get baselineResult => results.firstWhere(
        (r) => r.scenario.isBaseline,
        orElse: () => results.first,
      );

  /// Get alternative scenarios (non-baseline)
  List<ExitSimulationResult> get alternativeResults =>
      results.where((r) => !r.scenario.isBaseline).toList();

  /// Is viewing baseline?
  bool get isViewingBaseline => selectedResult.scenario.isBaseline;

  ExitSimulatorLoaded copyWith({
    List<ExitSimulationResult>? results,
    ExitSimulationResult? selectedResult,
    SimulationComparison? bestComparison,
    double? liquidCash,
    double? monthlyBurnRate,
    double? monthlyPassiveIncome,
  }) {
    return ExitSimulatorLoaded(
      results: results ?? this.results,
      selectedResult: selectedResult ?? this.selectedResult,
      bestComparison: bestComparison ?? this.bestComparison,
      liquidCash: liquidCash ?? this.liquidCash,
      monthlyBurnRate: monthlyBurnRate ?? this.monthlyBurnRate,
      monthlyPassiveIncome: monthlyPassiveIncome ?? this.monthlyPassiveIncome,
    );
  }

  @override
  List<Object?> get props => [
        results,
        selectedResult,
        bestComparison,
        liquidCash,
        monthlyBurnRate,
        monthlyPassiveIncome,
      ];
}

/// Error state
class ExitSimulatorError extends ExitSimulatorState {
  final String message;

  const ExitSimulatorError({required this.message});

  @override
  List<Object?> get props => [message];
}
