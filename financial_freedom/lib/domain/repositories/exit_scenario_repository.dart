import 'package:financial_freedom/domain/entities/exit_scenario.dart';

/// Repository interface for Exit Scenarios
abstract class ExitScenarioRepository {
  /// Get all scenarios
  Future<List<ExitScenario>> getAllScenarios();

  /// Get default scenarios only
  Future<List<ExitScenario>> getDefaultScenarios();

  /// Get the baseline scenario
  Future<ExitScenario?> getBaselineScenario();

  /// Get scenario by ID
  Future<ExitScenario?> getScenarioById(String id);

  /// Save a scenario (insert or update)
  Future<void> saveScenario(ExitScenario scenario);

  /// Save multiple scenarios
  Future<void> saveScenarios(List<ExitScenario> scenarios);

  /// Delete a scenario
  Future<void> deleteScenario(String id);

  /// Delete all custom scenarios (non-default)
  Future<void> deleteCustomScenarios();

  /// Initialize default scenarios if not present
  Future<void> ensureDefaultScenarios();

  /// Watch all scenarios (for reactive UI)
  Stream<List<ExitScenario>> watchAllScenarios();
}
