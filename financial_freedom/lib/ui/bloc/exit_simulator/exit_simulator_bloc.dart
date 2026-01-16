import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/core/services/scenario_engine.dart';
import 'package:financial_freedom/data/repositories/financial_data_repository_impl.dart';
import 'package:financial_freedom/domain/entities/exit_simulation_result.dart';

part 'exit_simulator_event.dart';
part 'exit_simulator_state.dart';

/// BLoC for Exit Simulator - Weekly Projection Engine
///
/// Manages the state of exit simulations and "What If" scenarios.
class ExitSimulatorBloc extends Bloc<ExitSimulatorEvent, ExitSimulatorState> {
  final ScenarioEngine _scenarioEngine;
  final FinancialDataRepositoryImpl _financialDataRepository;

  ExitSimulatorBloc({
    required ScenarioEngine scenarioEngine,
    required FinancialDataRepositoryImpl financialDataRepository,
  })  : _scenarioEngine = scenarioEngine,
        _financialDataRepository = financialDataRepository,
        super(const ExitSimulatorInitial()) {
    on<InitializeSimulatorEvent>(_onInitialize);
    on<RunSimulationEvent>(_onRunSimulation);
    on<SelectScenarioEvent>(_onSelectScenario);
    on<RefreshSimulationEvent>(_onRefresh);
  }

  Future<void> _onInitialize(
    InitializeSimulatorEvent event,
    Emitter<ExitSimulatorState> emit,
  ) async {
    emit(const ExitSimulatorLoading());

    try {
      // Check if we have existing simulations
      final hasSimulations = await _scenarioEngine.hasSimulations();

      if (hasSimulations) {
        // Load existing results
        // For now, we'll need to re-run simulation
        // In a production app, we'd cache the results
        emit(ExitSimulatorReady(
          hasExistingSimulation: hasSimulations,
        ));
      } else {
        emit(const ExitSimulatorReady(hasExistingSimulation: false));
      }
    } catch (e) {
      emit(ExitSimulatorError(message: e.toString()));
    }
  }

  Future<void> _onRunSimulation(
    RunSimulationEvent event,
    Emitter<ExitSimulatorState> emit,
  ) async {
    emit(const ExitSimulatorRunning());

    try {
      // Get financial data
      final accounts = await _financialDataRepository.getAllAccounts();
      final baseline = await _financialDataRepository.getLatestBaseline();
      final assets = await _financialDataRepository.getAllAssets();
      final liabilities = await _financialDataRepository.getAllLiabilities();

      // Calculate totals
      double liquidCash = 0;
      for (final account in accounts) {
        if (account.isLiquid) {
          liquidCash += account.balance;
        }
      }

      // Add liquid assets
      for (final asset in assets) {
        // Consider savings and some investments as liquid
        if (asset.type.name == 'savings') {
          liquidCash += asset.currentValue;
        }
      }

      // Calculate monthly burn rate from baseline
      double monthlyBurnRate = 0;
      if (baseline != null) {
        monthlyBurnRate = baseline.totalBaseline;
      }

      // Calculate passive income
      double monthlyPassiveIncome = 0;
      for (final asset in assets) {
        monthlyPassiveIncome += asset.monthlyIncome;
      }

      // Calculate debt payments
      double monthlyDebtPayments = 0;
      for (final liability in liabilities) {
        monthlyDebtPayments += liability.monthlyPayment;
      }

      // If no data, show empty state
      if (liquidCash <= 0 && monthlyBurnRate <= 0) {
        emit(const ExitSimulatorEmpty(
          message: 'Belum ada data keuangan untuk simulasi.\n'
              'Lengkapi dulu data akun dan pengeluaran bulananmu.',
        ));
        return;
      }

      // Run simulations for all scenarios
      final results = await _scenarioEngine.runAllScenarios(
        liquidCash: liquidCash,
        monthlyBurnRate: monthlyBurnRate,
        monthlyPassiveIncome: monthlyPassiveIncome,
        monthlyDebtPayments: monthlyDebtPayments,
      );

      // Get baseline result
      final baselineResult = results.firstWhere(
        (r) => r.scenario.isBaseline,
        orElse: () => results.first,
      );

      // Get best comparison
      final bestComparison = _scenarioEngine.getBestComparison(results);

      emit(ExitSimulatorLoaded(
        results: results,
        selectedResult: baselineResult,
        bestComparison: bestComparison,
        liquidCash: liquidCash,
        monthlyBurnRate: monthlyBurnRate,
        monthlyPassiveIncome: monthlyPassiveIncome,
      ));
    } catch (e) {
      emit(ExitSimulatorError(
        message: 'Gagal menjalankan simulasi: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSelectScenario(
    SelectScenarioEvent event,
    Emitter<ExitSimulatorState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExitSimulatorLoaded) {
      final selected = currentState.results.firstWhere(
        (r) => r.scenario.id == event.scenarioId,
        orElse: () => currentState.selectedResult,
      );

      emit(currentState.copyWith(selectedResult: selected));
    }
  }

  Future<void> _onRefresh(
    RefreshSimulationEvent event,
    Emitter<ExitSimulatorState> emit,
  ) async {
    // Clear existing simulations and re-run
    await _scenarioEngine.clearAllSimulations();
    add(const RunSimulationEvent());
  }
}
