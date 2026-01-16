import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/domain/entities/exit_zone.dart';
import 'package:financial_freedom/domain/entities/weekly_projection.dart';
import 'package:financial_freedom/domain/repositories/weekly_projection_repository.dart';

/// Implementation of WeeklyProjectionRepository using Drift
class WeeklyProjectionRepositoryImpl implements WeeklyProjectionRepository {
  final AppDatabase _database;

  WeeklyProjectionRepositoryImpl(this._database);

  @override
  Future<List<WeeklyProjection>> getProjectionsForScenario(
    String scenarioId,
  ) async {
    final data =
        await _database.weeklyProjectionDao.getProjectionsForScenario(scenarioId);
    return data.map(_mapToEntity).toList();
  }

  @override
  Future<List<WeeklyProjection>> getProjectionsInRange(
    String scenarioId,
    int startWeek,
    int endWeek,
  ) async {
    final data = await _database.weeklyProjectionDao.getProjectionsInRange(
      scenarioId,
      startWeek,
      endWeek,
    );
    return data.map(_mapToEntity).toList();
  }

  @override
  Future<List<WeeklyProjection>> getProjectionsByZone(
    String scenarioId,
    ExitZone zone,
  ) async {
    final data = await _database.weeklyProjectionDao.getProjectionsByZone(
      scenarioId,
      zone.dbValue,
    );
    return data.map(_mapToEntity).toList();
  }

  @override
  Future<WeeklyProjection?> getFirstWeekInZone(
    String scenarioId,
    ExitZone zone,
  ) async {
    final data = await _database.weeklyProjectionDao.getFirstWeekInZone(
      scenarioId,
      zone.dbValue,
    );
    return data != null ? _mapToEntity(data) : null;
  }

  @override
  Future<WeeklyProjection?> getWeekProjection(
    String scenarioId,
    int weekNumber,
  ) async {
    final data = await _database.weeklyProjectionDao.getWeekProjection(
      scenarioId,
      weekNumber,
    );
    return data != null ? _mapToEntity(data) : null;
  }

  @override
  Future<void> saveProjection(WeeklyProjection projection) async {
    await _database.weeklyProjectionDao
        .insertProjection(_mapToCompanion(projection));
  }

  @override
  Future<void> saveProjections(List<WeeklyProjection> projections) async {
    final companions = projections.map(_mapToCompanion).toList();
    await _database.weeklyProjectionDao.insertProjections(companions);
  }

  @override
  Future<void> replaceProjectionsForScenario(
    String scenarioId,
    List<WeeklyProjection> projections,
  ) async {
    final companions = projections.map(_mapToCompanion).toList();
    await _database.weeklyProjectionDao.replaceProjectionsForScenario(
      scenarioId,
      companions,
    );
  }

  @override
  Future<void> deleteProjectionsForScenario(String scenarioId) async {
    await _database.weeklyProjectionDao.deleteProjectionsForScenario(scenarioId);
  }

  @override
  Future<void> deleteAllProjections() async {
    await _database.weeklyProjectionDao.deleteAllProjections();
  }

  @override
  Future<int> countProjections(String scenarioId) async {
    return _database.weeklyProjectionDao.countProjections(scenarioId);
  }

  @override
  Stream<List<WeeklyProjection>> watchProjectionsForScenario(
    String scenarioId,
  ) {
    return _database.weeklyProjectionDao
        .watchProjectionsForScenario(scenarioId)
        .map((list) => list.map(_mapToEntity).toList());
  }

  @override
  Future<Map<ExitZone, int>> getZoneSummary(String scenarioId) async {
    final summary =
        await _database.weeklyProjectionDao.getZoneSummary(scenarioId);
    return summary.map(
      (key, value) => MapEntry(ExitZoneX.fromDbValue(key), value),
    );
  }

  // Mapping functions
  WeeklyProjection _mapToEntity(WeeklyProjectionsTableData data) {
    return WeeklyProjection(
      id: data.id,
      scenarioId: data.scenarioId,
      weekNumber: data.weekNumber,
      startingBalance: data.startingBalance,
      income: data.income,
      expenses: data.expenses,
      endingBalance: data.endingBalance,
      zone: ExitZoneX.fromDbValue(data.zone),
      createdAt: data.createdAt,
    );
  }

  WeeklyProjectionsTableCompanion _mapToCompanion(WeeklyProjection entity) {
    return WeeklyProjectionsTableCompanion(
      id: Value(entity.id),
      scenarioId: Value(entity.scenarioId),
      weekNumber: Value(entity.weekNumber),
      startingBalance: Value(entity.startingBalance),
      income: Value(entity.income),
      expenses: Value(entity.expenses),
      endingBalance: Value(entity.endingBalance),
      zone: Value(entity.zone.dbValue),
      createdAt: Value(entity.createdAt),
    );
  }
}
