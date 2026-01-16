import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/daily_compass_table.dart';

part 'daily_compass_dao.g.dart';

@DriftAccessor(tables: [DailyCompass])
class DailyCompassDao extends DatabaseAccessor<AppDatabase>
    with _$DailyCompassDaoMixin {
  DailyCompassDao(super.db);

  /// Get all compass entries
  Future<List<DailyCompassData>> getAllCompassEntries() {
    return (select(dailyCompass)..orderBy([(c) => OrderingTerm.desc(c.date)]))
        .get();
  }

  /// Get compass entry by id
  Future<DailyCompassData?> getCompassById(int id) {
    return (select(dailyCompass)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get compass entry for today
  Future<DailyCompassData?> getTodayCompass() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return (select(dailyCompass)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(startOfDay) &
              c.date.isSmallerOrEqualValue(endOfDay)))
        .getSingleOrNull();
  }

  /// Get compass entry for a specific date
  Future<DailyCompassData?> getCompassForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return (select(dailyCompass)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(startOfDay) &
              c.date.isSmallerOrEqualValue(endOfDay)))
        .getSingleOrNull();
  }

  /// Get compass entries within a date range
  Future<List<DailyCompassData>> getCompassEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(dailyCompass)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(startDate) &
              c.date.isSmallerOrEqualValue(endDate))
          ..orderBy([(c) => OrderingTerm.desc(c.date)]))
        .get();
  }

  /// Get completion rate for a date range
  Future<double> getCompletionRate(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entries = await getCompassEntriesByDateRange(startDate, endDate);
    if (entries.isEmpty) return 0.0;

    final completedCount = entries.where((e) => e.completed).length;
    return completedCount / entries.length;
  }

  /// Insert a new compass entry
  Future<int> insertCompassEntry(DailyCompassCompanion entry) {
    return into(dailyCompass).insert(entry);
  }

  /// Update a compass entry
  Future<bool> updateCompassEntry(DailyCompassData entry) {
    return update(dailyCompass).replace(entry);
  }

  /// Insert or update compass entry for today
  Future<int> upsertTodayCompass(DailyCompassCompanion entry) {
    return into(dailyCompass).insertOnConflictUpdate(entry);
  }

  /// Mark compass entry as completed
  Future<int> markCompleted(int id, {String? notes}) {
    return (update(dailyCompass)..where((c) => c.id.equals(id))).write(
      DailyCompassCompanion(
        completed: const Value(true),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a compass entry
  Future<int> deleteCompassEntry(int id) {
    return (delete(dailyCompass)..where((c) => c.id.equals(id))).go();
  }

  /// Watch today's compass
  Stream<DailyCompassData?> watchTodayCompass() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return (select(dailyCompass)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(startOfDay) &
              c.date.isSmallerOrEqualValue(endOfDay)))
        .watchSingleOrNull();
  }

  /// Watch all compass entries
  Stream<List<DailyCompassData>> watchAllCompassEntries() {
    return (select(dailyCompass)..orderBy([(c) => OrderingTerm.desc(c.date)]))
        .watch();
  }
}
