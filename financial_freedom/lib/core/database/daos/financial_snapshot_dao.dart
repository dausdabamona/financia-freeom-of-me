import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/financial_snapshots_table.dart';

part 'financial_snapshot_dao.g.dart';

@DriftAccessor(tables: [FinancialSnapshots])
class FinancialSnapshotDao extends DatabaseAccessor<AppDatabase>
    with _$FinancialSnapshotDaoMixin {
  FinancialSnapshotDao(super.db);

  /// Get all snapshots
  Future<List<FinancialSnapshot>> getAllSnapshots() {
    return (select(financialSnapshots)
          ..orderBy([(s) => OrderingTerm.desc(s.date)]))
        .get();
  }

  /// Get snapshot by id
  Future<FinancialSnapshot?> getSnapshotById(int id) {
    return (select(financialSnapshots)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get the latest snapshot
  Future<FinancialSnapshot?> getLatestSnapshot() {
    return (select(financialSnapshots)
          ..orderBy([(s) => OrderingTerm.desc(s.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get snapshot for today
  Future<FinancialSnapshot?> getTodaySnapshot() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return (select(financialSnapshots)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(startOfDay) &
              s.date.isSmallerOrEqualValue(endOfDay)))
        .getSingleOrNull();
  }

  /// Get snapshots within a date range
  Future<List<FinancialSnapshot>> getSnapshotsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(financialSnapshots)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(startDate) &
              s.date.isSmallerOrEqualValue(endDate))
          ..orderBy([(s) => OrderingTerm.desc(s.date)]))
        .get();
  }

  /// Insert a new snapshot
  Future<int> insertSnapshot(FinancialSnapshotsCompanion snapshot) {
    return into(financialSnapshots).insert(snapshot);
  }

  /// Update a snapshot
  Future<bool> updateSnapshot(FinancialSnapshot snapshot) {
    return update(financialSnapshots).replace(snapshot);
  }

  /// Insert or update snapshot for today (by date)
  Future<int> upsertTodaySnapshot(FinancialSnapshotsCompanion snapshot) {
    return into(financialSnapshots).insertOnConflictUpdate(snapshot);
  }

  /// Delete a snapshot
  Future<int> deleteSnapshot(int id) {
    return (delete(financialSnapshots)..where((s) => s.id.equals(id))).go();
  }

  /// Watch the latest snapshot
  Stream<FinancialSnapshot?> watchLatestSnapshot() {
    return (select(financialSnapshots)
          ..orderBy([(s) => OrderingTerm.desc(s.date)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Watch all snapshots
  Stream<List<FinancialSnapshot>> watchAllSnapshots() {
    return (select(financialSnapshots)
          ..orderBy([(s) => OrderingTerm.desc(s.date)]))
        .watch();
  }
}
