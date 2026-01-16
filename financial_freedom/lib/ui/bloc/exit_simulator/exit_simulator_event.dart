part of 'exit_simulator_bloc.dart';

/// Events for Exit Simulator BLoC
abstract class ExitSimulatorEvent extends Equatable {
  const ExitSimulatorEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the simulator
class InitializeSimulatorEvent extends ExitSimulatorEvent {
  const InitializeSimulatorEvent();
}

/// Run simulation for all scenarios
class RunSimulationEvent extends ExitSimulatorEvent {
  const RunSimulationEvent();
}

/// Select a specific scenario to view
class SelectScenarioEvent extends ExitSimulatorEvent {
  final String scenarioId;

  const SelectScenarioEvent({required this.scenarioId});

  @override
  List<Object?> get props => [scenarioId];
}

/// Refresh simulation with latest data
class RefreshSimulationEvent extends ExitSimulatorEvent {
  const RefreshSimulationEvent();
}
