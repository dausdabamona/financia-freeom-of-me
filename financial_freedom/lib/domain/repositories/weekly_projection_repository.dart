import 'package:financial_freedom/domain/entities/exit_zone.dart';
import 'package:financial_freedom/domain/entities/weekly_projection.dart';

/// Repository interface for Weekly Exit Projections
abstract class WeeklyProjectionRepository {
  /// Get all projections for a scenario
  Future<List<WeeklyProjection>> getProjectionsForScenario(String scenarioId);

  /// Get projections within a week range
  Future<List<WeeklyProjection>> getProjectionsInRange(
    String scenarioId,
    int startWeek,
    int endWeek,
  );

  /// Get projections by zone
  Future<List<WeeklyProjection>> getProjectionsByZone(
    String scenarioId,
    ExitZone zone,
  );

  /// Get first week in a specific zone
  Future<WeeklyProjection?> getFirstWeekInZone(
    String scenarioId,
    ExitZone zone,
  );

  /// Get a specific week's projection
  Future<WeeklyProjection?> getWeekProjection(
    String scenarioId,
    int weekNumber,
  );

  /// Save a projection
  Future<void> saveProjection(WeeklyProjection projection);

  /// Save multiple projections
  Future<void> saveProjections(List<WeeklyProjection> projections);

  /// Replace all projections for a scenario
  Future<void> replaceProjectionsForScenario(
    String scenarioId,
    List<WeeklyProjection> projections,
  );

  /// Delete all projections for a scenario
  Future<void> deleteProjectionsForScenario(String scenarioId);

  /// Delete all projections
  Future<void> deleteAllProjections();

  /// Count projections for a scenario
  Future<int> countProjections(String scenarioId);

  /// Watch projections for a scenario (for reactive UI)
  Stream<List<WeeklyProjection>> watchProjectionsForScenario(String scenarioId);

  /// Get zone summary (count per zone)
  Future<Map<ExitZone, int>> getZoneSummary(String scenarioId);
}
