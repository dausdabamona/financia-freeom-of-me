import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/weekly_projections_table.dart';

part 'weekly_projection_dao.g.dart';

/// Data Access Object for Weekly Exit Projections
@DriftAccessor(tables: [WeeklyProjectionsTable])
class WeeklyProjectionDao extends DatabaseAccessor<AppDatabase>
    with _$WeeklyProjectionDaoMixin {
  WeeklyProjectionDao(super.db);

  /// Get all projections for a scenario
  Future<List<WeeklyProjectionsTableData>> getProjectionsForScenario(
    String scenarioId,
  ) {
    return (select(weeklyProjectionsTable)
          ..where((t) => t.scenarioId.equals(scenarioId))
          ..orderBy([(t) => OrderingTerm.asc(t.weekNumber)]))
        .get();
  }

  /// Get projections for a scenario within a range
  Future<List<WeeklyProjectionsTableData>> getProjectionsInRange(
    String scenarioId,
    int startWeek,
    int endWeek,
  ) {
    return (select(weeklyProjectionsTable)
          ..where((t) =>
              t.scenarioId.equals(scenarioId) &
              t.weekNumber.isBiggerOrEqualValue(startWeek) &
              t.weekNumber.isSmallerOrEqualValue(endWeek))
          ..orderBy([(t) => OrderingTerm.asc(t.weekNumber)]))
        .get();
  }

  /// Get projections by zone
  Future<List<WeeklyProjectionsTableData>> getProjectionsByZone(
    String scenarioId,
    String zone,
  ) {
    return (select(weeklyProjectionsTable)
          ..where(
              (t) => t.scenarioId.equals(scenarioId) & t.zone.equals(zone))
          ..orderBy([(t) => OrderingTerm.asc(t.weekNumber)]))
        .get();
  }

  /// Get first week in a specific zone
  Future<WeeklyProjectionsTableData?> getFirstWeekInZone(
    String scenarioId,
    String zone,
  ) {
    return (select(weeklyProjectionsTable)
          ..where(
              (t) => t.scenarioId.equals(scenarioId) & t.zone.equals(zone))
          ..orderBy([(t) => OrderingTerm.asc(t.weekNumber)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get specific week projection
  Future<WeeklyProjectionsTableData?> getWeekProjection(
    String scenarioId,
    int weekNumber,
  ) {
    return (select(weeklyProjectionsTable)
          ..where((t) =>
              t.scenarioId.equals(scenarioId) &
              t.weekNumber.equals(weekNumber)))
        .getSingleOrNull();
  }

  /// Insert a projection
  Future<void> insertProjection(WeeklyProjectionsTableCompanion projection) {
    return into(weeklyProjectionsTable).insert(projection);
  }

  /// Insert multiple projections (batch insert for performance)
  Future<void> insertProjections(
    List<WeeklyProjectionsTableCompanion> projections,
  ) {
    return batch((batch) {
      batch.insertAll(weeklyProjectionsTable, projections);
    });
  }

  /// Replace all projections for a scenario
  Future<void> replaceProjectionsForScenario(
    String scenarioId,
    List<WeeklyProjectionsTableCompanion> projections,
  ) async {
    await transaction(() async {
      // Delete existing projections
      await (delete(weeklyProjectionsTable)
            ..where((t) => t.scenarioId.equals(scenarioId)))
          .go();
      // Insert new projections
      await batch((batch) {
        batch.insertAll(weeklyProjectionsTable, projections);
      });
    });
  }

  /// Delete all projections for a scenario
  Future<int> deleteProjectionsForScenario(String scenarioId) {
    return (delete(weeklyProjectionsTable)
          ..where((t) => t.scenarioId.equals(scenarioId)))
        .go();
  }

  /// Delete all projections
  Future<int> deleteAllProjections() {
    return delete(weeklyProjectionsTable).go();
  }

  /// Count projections for a scenario
  Future<int> countProjections(String scenarioId) async {
    final count = await (selectOnly(weeklyProjectionsTable)
          ..where(weeklyProjectionsTable.scenarioId.equals(scenarioId))
          ..addColumns([weeklyProjectionsTable.id.count()]))
        .map((row) => row.read(weeklyProjectionsTable.id.count()))
        .getSingle();
    return count ?? 0;
  }

  /// Watch projections for a scenario (for reactive UI)
  Stream<List<WeeklyProjectionsTableData>> watchProjectionsForScenario(
    String scenarioId,
  ) {
    return (select(weeklyProjectionsTable)
          ..where((t) => t.scenarioId.equals(scenarioId))
          ..orderBy([(t) => OrderingTerm.asc(t.weekNumber)]))
        .watch();
  }

  /// Get zone summary for a scenario
  Future<Map<String, int>> getZoneSummary(String scenarioId) async {
    final projections = await getProjectionsForScenario(scenarioId);
    final summary = <String, int>{};

    for (final p in projections) {
      summary[p.zone] = (summary[p.zone] ?? 0) + 1;
    }

    return summary;
  }
}
