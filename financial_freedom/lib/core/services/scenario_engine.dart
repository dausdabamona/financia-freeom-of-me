import 'package:financial_freedom/core/services/weekly_exit_simulator.dart';
import 'package:financial_freedom/domain/entities/exit_scenario.dart';
import 'package:financial_freedom/domain/entities/exit_simulation_result.dart';
import 'package:financial_freedom/domain/repositories/exit_scenario_repository.dart';
import 'package:financial_freedom/domain/repositories/weekly_projection_repository.dart';

/// Scenario Engine - Orchestrates multi-scenario simulations
///
/// Philosophy: Every scenario is a potential future.
/// This engine helps visualize multiple futures simultaneously,
/// empowering informed decision-making without fear.
class ScenarioEngine {
  final WeeklyExitSimulator _simulator;
  final ExitScenarioRepository _scenarioRepository;
  final WeeklyProjectionRepository _projectionRepository;

  ScenarioEngine({
    required WeeklyExitSimulator simulator,
    required ExitScenarioRepository scenarioRepository,
    required WeeklyProjectionRepository projectionRepository,
  })  : _simulator = simulator,
        _scenarioRepository = scenarioRepository,
        _projectionRepository = projectionRepository;

  /// Run simulations for all scenarios
  Future<List<ExitSimulationResult>> runAllScenarios({
    required double liquidCash,
    required double monthlyBurnRate,
    required double monthlyPassiveIncome,
    required double monthlyDebtPayments,
  }) async {
    // Ensure default scenarios exist
    await _scenarioRepository.ensureDefaultScenarios();

    // Get all scenarios
    final scenarios = await _scenarioRepository.getAllScenarios();

    // Find baseline scenario first
    final baselineScenario = scenarios.firstWhere(
      (s) => s.isBaseline,
      orElse: () => scenarios.first,
    );

    // Run baseline simulation first
    final baselineResult = _simulator.runSimulation(
      liquidCash: liquidCash,
      monthlyBurnRate: monthlyBurnRate,
      monthlyPassiveIncome: monthlyPassiveIncome,
      monthlyDebtPayments: monthlyDebtPayments,
      scenario: baselineScenario,
    );

    // Store baseline projections
    await _projectionRepository.replaceProjectionsForScenario(
      baselineScenario.id,
      baselineResult.weeklyProjections,
    );

    final results = <ExitSimulationResult>[baselineResult];

    // Run other scenarios with comparison
    for (final scenario in scenarios) {
      if (scenario.isBaseline) continue;

      final result = _simulator.runSimulationWithComparison(
        liquidCash: liquidCash,
        monthlyBurnRate: monthlyBurnRate,
        monthlyPassiveIncome: monthlyPassiveIncome,
        monthlyDebtPayments: monthlyDebtPayments,
        scenario: scenario,
        baselineResult: baselineResult,
      );

      // Store projections
      await _projectionRepository.replaceProjectionsForScenario(
        scenario.id,
        result.weeklyProjections,
      );

      results.add(result);
    }

    return results;
  }

  /// Run simulation for a single scenario
  Future<ExitSimulationResult> runSingleScenario({
    required ExitScenario scenario,
    required double liquidCash,
    required double monthlyBurnRate,
    required double monthlyPassiveIncome,
    required double monthlyDebtPayments,
    ExitSimulationResult? baselineResult,
  }) async {
    final result = _simulator.runSimulationWithComparison(
      liquidCash: liquidCash,
      monthlyBurnRate: monthlyBurnRate,
      monthlyPassiveIncome: monthlyPassiveIncome,
      monthlyDebtPayments: monthlyDebtPayments,
      scenario: scenario,
      baselineResult: baselineResult,
    );

    // Store projections
    await _projectionRepository.replaceProjectionsForScenario(
      scenario.id,
      result.weeklyProjections,
    );

    return result;
  }

  /// Get the best scenario based on weeks safe
  ExitSimulationResult? findBestScenario(List<ExitSimulationResult> results) {
    if (results.isEmpty) return null;

    return results.reduce((best, current) {
      return current.insight.weeksSafe > best.insight.weeksSafe
          ? current
          : best;
    });
  }

  /// Get comparison between baseline and best alternative
  SimulationComparison? getBestComparison(List<ExitSimulationResult> results) {
    if (results.length < 2) return null;

    final baseline = results.firstWhere(
      (r) => r.scenario.isBaseline,
      orElse: () => results.first,
    );

    final alternatives = results.where((r) => !r.scenario.isBaseline).toList();
    if (alternatives.isEmpty) return null;

    final best = alternatives.reduce((best, current) {
      return current.insight.weeksSafe > best.insight.weeksSafe
          ? current
          : best;
    });

    return SimulationComparison(baseline: baseline, alternative: best);
  }

  /// Generate a summary message for all scenarios
  String generateSummaryMessage(List<ExitSimulationResult> results) {
    if (results.isEmpty) {
      return 'Belum ada data untuk simulasi.';
    }

    final baseline = results.firstWhere(
      (r) => r.scenario.isBaseline,
      orElse: () => results.first,
    );

    final parts = <String>[
      'Situasi baseline: ${baseline.insight.emotionalMessage}',
    ];

    final comparison = getBestComparison(results);
    if (comparison != null && comparison.isAlternativeBetter) {
      parts.add('');
      parts.add(comparison.comparisonMessage);
    }

    return parts.join('\n');
  }

  /// Get stored projections for a scenario
  Future<List<dynamic>> getStoredProjections(String scenarioId) async {
    return _projectionRepository.getProjectionsForScenario(scenarioId);
  }

  /// Clear all stored simulations
  Future<void> clearAllSimulations() async {
    await _projectionRepository.deleteAllProjections();
  }

  /// Check if simulations have been run
  Future<bool> hasSimulations() async {
    final baseline = await _scenarioRepository.getBaselineScenario();
    if (baseline == null) return false;

    final count = await _projectionRepository.countProjections(baseline.id);
    return count > 0;
  }
}
