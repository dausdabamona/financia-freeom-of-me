import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/exit_scenarios_table.dart';

part 'exit_scenario_dao.g.dart';

/// Data Access Object for Exit Scenarios
@DriftAccessor(tables: [ExitScenariosTable])
class ExitScenarioDao extends DatabaseAccessor<AppDatabase>
    with _$ExitScenarioDaoMixin {
  ExitScenarioDao(super.db);

  /// Get all scenarios
  Future<List<ExitScenariosTableData>> getAllScenarios() {
    return (select(exitScenariosTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.isBaseline, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Get default scenarios only
  Future<List<ExitScenariosTableData>> getDefaultScenarios() {
    return (select(exitScenariosTable)
          ..where((t) => t.isDefault.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.isBaseline, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Get the baseline scenario
  Future<ExitScenariosTableData?> getBaselineScenario() {
    return (select(exitScenariosTable)
          ..where((t) => t.isBaseline.equals(true)))
        .getSingleOrNull();
  }

  /// Get scenario by ID
  Future<ExitScenariosTableData?> getScenarioById(String id) {
    return (select(exitScenariosTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert or update a scenario
  Future<void> upsertScenario(ExitScenariosTableCompanion scenario) {
    return into(exitScenariosTable).insertOnConflictUpdate(scenario);
  }

  /// Insert multiple scenarios
  Future<void> insertScenarios(List<ExitScenariosTableCompanion> scenarios) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(exitScenariosTable, scenarios);
    });
  }

  /// Delete a scenario
  Future<int> deleteScenario(String id) {
    return (delete(exitScenariosTable)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all non-default scenarios
  Future<int> deleteCustomScenarios() {
    return (delete(exitScenariosTable)
          ..where((t) => t.isDefault.equals(false)))
        .go();
  }

  /// Check if default scenarios exist
  Future<bool> hasDefaultScenarios() async {
    final count = await (selectOnly(exitScenariosTable)
          ..where(exitScenariosTable.isDefault.equals(true))
          ..addColumns([exitScenariosTable.id.count()]))
        .map((row) => row.read(exitScenariosTable.id.count()))
        .getSingle();
    return (count ?? 0) > 0;
  }

  /// Watch all scenarios (for reactive UI)
  Stream<List<ExitScenariosTableData>> watchAllScenarios() {
    return (select(exitScenariosTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.isBaseline, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }
}
