import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/core/services/freedom_calculator.dart';
import 'package:intl/intl.dart';

/// Repository for aggregating all financial data needed for calculations
class FinancialDataRepositoryImpl {
  final AppDatabase _database;

  FinancialDataRepositoryImpl(this._database);

  /// Get current month in YYYY-MM format
  String get _currentMonth => DateFormat('yyyy-MM').format(DateTime.now());

  /// Collect all financial data for calculations
  Future<Either<Failure, FinancialData>> getFinancialData() async {
    try {
      // Get baseline costs
      final baseline =
          await _database.monthlyBaselineDao.getBaselineForMonth(_currentMonth);
      final latestBaseline =
          baseline ?? await _database.monthlyBaselineDao.getLatestBaseline();

      // Get debt payments from liabilities
      final totalDebtPayments =
          await _database.liabilityDao.getTotalMonthlyPayment();

      // Get liquid assets from accounts
      final liquidAccountBalance =
          await _database.accountDao.getTotalLiquidBalance();

      // Get asset values
      final totalAssetValue = await _database.assetDao.getTotalLiquidValue();
      final assetPassiveIncome =
          await _database.assetDao.getTotalMonthlyPassiveIncome();

      // Get total liabilities
      final totalLiabilities =
          await _database.liabilityDao.getTotalRemainingBalance();

      // Get income data for current month
      final totalIncome =
          await _database.transactionDao.getTotalIncomeForMonth(_currentMonth);
      final salaryIncome =
          await _database.transactionDao.getSalaryIncomeForMonth(_currentMonth);
      final passiveIncome =
          await _database.transactionDao.getPassiveIncomeForMonth(_currentMonth);

      // Total liquid assets = liquid accounts + liquid asset value
      final totalLiquidAssets = liquidAccountBalance + totalAssetValue;

      return Right(FinancialData(
        essentialCost: latestBaseline?.essentialCost ?? 0,
        optionalCost: latestBaseline?.optionalCost ?? 0,
        safetyBuffer: latestBaseline?.safetyBuffer ?? 0,
        totalDebtPayments: totalDebtPayments,
        totalLiquidAssets: totalLiquidAssets,
        totalMonthlyIncome: totalIncome,
        salaryIncome: salaryIncome,
        passiveIncome: passiveIncome,
        totalAssetValue: totalAssetValue,
        assetPassiveIncome: assetPassiveIncome,
        totalLiabilities: totalLiabilities,
      ));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to collect financial data: $e',
      ));
    }
  }
}
