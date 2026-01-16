import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/monthly_baseline_table.dart';

part 'monthly_baseline_dao.g.dart';

@DriftAccessor(tables: [MonthlyBaselines])
class MonthlyBaselineDao extends DatabaseAccessor<AppDatabase>
    with _$MonthlyBaselineDaoMixin {
  MonthlyBaselineDao(super.db);

  /// Get all baselines
  Future<List<MonthlyBaseline>> getAllBaselines() =>
      select(monthlyBaselines).get();

  /// Get baseline for a specific month (YYYY-MM)
  Future<MonthlyBaseline?> getBaselineForMonth(String month) {
    return (select(monthlyBaselines)..where((b) => b.month.equals(month)))
        .getSingleOrNull();
  }

  /// Get the most recent baseline
  Future<MonthlyBaseline?> getLatestBaseline() {
    return (select(monthlyBaselines)
          ..orderBy([(b) => OrderingTerm.desc(b.month)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Insert or update baseline for a month
  Future<int> upsertBaseline(MonthlyBaselinesCompanion baseline) {
    return into(monthlyBaselines).insertOnConflictUpdate(baseline);
  }

  /// Delete a baseline
  Future<int> deleteBaseline(int id) {
    return (delete(monthlyBaselines)..where((b) => b.id.equals(id))).go();
  }

  /// Watch baseline for a specific month
  Stream<MonthlyBaseline?> watchBaselineForMonth(String month) {
    return (select(monthlyBaselines)..where((b) => b.month.equals(month)))
        .watchSingleOrNull();
  }

  /// Watch latest baseline
  Stream<MonthlyBaseline?> watchLatestBaseline() {
    return (select(monthlyBaselines)
          ..orderBy([(b) => OrderingTerm.desc(b.month)])
          ..limit(1))
        .watchSingleOrNull();
  }
}
