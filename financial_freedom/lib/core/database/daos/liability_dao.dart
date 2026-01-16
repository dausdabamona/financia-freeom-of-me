import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/liabilities_table.dart';

part 'liability_dao.g.dart';

@DriftAccessor(tables: [Liabilities])
class LiabilityDao extends DatabaseAccessor<AppDatabase>
    with _$LiabilityDaoMixin {
  LiabilityDao(super.db);

  /// Get all liabilities
  Future<List<Liability>> getAllLiabilities() => select(liabilities).get();

  /// Get liability by id
  Future<Liability?> getLiabilityById(int id) {
    return (select(liabilities)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get total remaining balance of all liabilities
  Future<double> getTotalRemainingBalance() async {
    final allLiabilities = await getAllLiabilities();
    return allLiabilities.fold<double>(
        0.0, (sum, liability) => sum + liability.remainingBalance);
  }

  /// Get total monthly payment of all liabilities
  Future<double> getTotalMonthlyPayment() async {
    final allLiabilities = await getAllLiabilities();
    return allLiabilities.fold<double>(
        0.0, (sum, liability) => sum + liability.monthlyPayment);
  }

  /// Insert a new liability
  Future<int> insertLiability(LiabilitiesCompanion liability) {
    return into(liabilities).insert(liability);
  }

  /// Update a liability
  Future<bool> updateLiability(Liability liability) {
    return update(liabilities).replace(liability);
  }

  /// Delete a liability
  Future<int> deleteLiability(int id) {
    return (delete(liabilities)..where((l) => l.id.equals(id))).go();
  }

  /// Watch all liabilities
  Stream<List<Liability>> watchAllLiabilities() => select(liabilities).watch();
}
