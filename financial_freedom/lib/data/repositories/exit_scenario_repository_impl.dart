import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/domain/entities/exit_scenario.dart';
import 'package:financial_freedom/domain/repositories/exit_scenario_repository.dart';

/// Implementation of ExitScenarioRepository using Drift
class ExitScenarioRepositoryImpl implements ExitScenarioRepository {
  final AppDatabase _database;

  ExitScenarioRepositoryImpl(this._database);

  @override
  Future<List<ExitScenario>> getAllScenarios() async {
    final data = await _database.exitScenarioDao.getAllScenarios();
    return data.map(_mapToEntity).toList();
  }

  @override
  Future<List<ExitScenario>> getDefaultScenarios() async {
    final data = await _database.exitScenarioDao.getDefaultScenarios();
    return data.map(_mapToEntity).toList();
  }

  @override
  Future<ExitScenario?> getBaselineScenario() async {
    final data = await _database.exitScenarioDao.getBaselineScenario();
    return data != null ? _mapToEntity(data) : null;
  }

  @override
  Future<ExitScenario?> getScenarioById(String id) async {
    final data = await _database.exitScenarioDao.getScenarioById(id);
    return data != null ? _mapToEntity(data) : null;
  }

  @override
  Future<void> saveScenario(ExitScenario scenario) async {
    await _database.exitScenarioDao.upsertScenario(_mapToCompanion(scenario));
  }

  @override
  Future<void> saveScenarios(List<ExitScenario> scenarios) async {
    final companions = scenarios.map(_mapToCompanion).toList();
    await _database.exitScenarioDao.insertScenarios(companions);
  }

  @override
  Future<void> deleteScenario(String id) async {
    await _database.exitScenarioDao.deleteScenario(id);
  }

  @override
  Future<void> deleteCustomScenarios() async {
    await _database.exitScenarioDao.deleteCustomScenarios();
  }

  @override
  Future<void> ensureDefaultScenarios() async {
    final hasDefaults = await _database.exitScenarioDao.hasDefaultScenarios();
    if (!hasDefaults) {
      final defaultScenarios = ExitScenario.defaultScenarios;
      await saveScenarios(defaultScenarios);
    }
  }

  @override
  Stream<List<ExitScenario>> watchAllScenarios() {
    return _database.exitScenarioDao
        .watchAllScenarios()
        .map((list) => list.map(_mapToEntity).toList());
  }

  // Mapping functions
  ExitScenario _mapToEntity(ExitScenariosTableData data) {
    return ExitScenario(
      id: data.id,
      name: data.name,
      description: data.description,
      weeklyBurnModifier: data.weeklyBurnModifier,
      weeklyIncomeModifier: data.weeklyIncomeModifier,
      debtReductionAmount: data.debtReductionAmount,
      isDefault: data.isDefault,
      isBaseline: data.isBaseline,
      createdAt: data.createdAt,
    );
  }

  ExitScenariosTableCompanion _mapToCompanion(ExitScenario entity) {
    return ExitScenariosTableCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      description: Value(entity.description),
      weeklyBurnModifier: Value(entity.weeklyBurnModifier),
      weeklyIncomeModifier: Value(entity.weeklyIncomeModifier),
      debtReductionAmount: Value(entity.debtReductionAmount),
      isDefault: Value(entity.isDefault),
      isBaseline: Value(entity.isBaseline),
      createdAt: Value(entity.createdAt),
    );
  }
}
