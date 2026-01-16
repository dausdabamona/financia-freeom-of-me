import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/database/app_database.dart' hide Asset, Liability;
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/core/services/freedom_calculator.dart';
import 'package:financial_freedom/domain/entities/account.dart' as domain;
import 'package:financial_freedom/domain/entities/asset.dart' as domain;
import 'package:financial_freedom/domain/entities/liability.dart' as domain;
import 'package:financial_freedom/domain/entities/monthly_baseline.dart' as domain;
import 'package:intl/intl.dart';

/// Repository for aggregating all financial data needed for calculations
class FinancialDataRepositoryImpl {
  final AppDatabase _database;

  FinancialDataRepositoryImpl(this._database);

  /// Get all accounts
  Future<List<domain.Account>> getAllAccounts() async {
    final accounts = await _database.accountDao.getAllAccounts();
    return accounts.map((a) => domain.Account(
      id: a.id.toString(),
      name: a.name,
      type: domain.AccountType.fromCode(a.type),
      balance: a.balance,
      isLiquid: a.isLiquid,
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
    )).toList();
  }

  /// Get latest baseline
  Future<domain.MonthlyBaseline?> getLatestBaseline() async {
    final baseline = await _database.monthlyBaselineDao.getLatestBaseline();
    if (baseline == null) return null;
    return domain.MonthlyBaseline(
      id: baseline.id.toString(),
      month: baseline.month,
      essentialCost: baseline.essentialCost,
      optionalCost: baseline.optionalCost,
      safetyBuffer: baseline.safetyBuffer,
      notes: baseline.notes,
      createdAt: baseline.createdAt,
      updatedAt: baseline.updatedAt,
    );
  }

  /// Get all assets
  Future<List<domain.Asset>> getAllAssets() async {
    final assets = await _database.assetDao.getAllAssets();
    return assets.map((a) => domain.Asset(
      id: a.id.toString(),
      name: a.name,
      type: domain.AssetType.values.firstWhere(
        (t) => t.name == a.type,
        orElse: () => domain.AssetType.other,
      ),
      currentValue: a.liquidValue,
      liquidValue: a.liquidValue,
      producesIncome: a.producesIncome,
      monthlyIncome: a.monthlyIncome,
      notes: a.notes,
      createdAt: a.createdAt,
      updatedAt: a.updatedAt,
    )).toList();
  }

  /// Get all liabilities
  Future<List<domain.Liability>> getAllLiabilities() async {
    final liabilities = await _database.liabilityDao.getAllLiabilities();
    return liabilities.map((l) => domain.Liability(
      id: l.id.toString(),
      name: l.name,
      type: domain.LiabilityType.values.firstWhere(
        (t) => t.name == l.type,
        orElse: () => domain.LiabilityType.other,
      ),
      remainingBalance: l.remainingBalance,
      monthlyPayment: l.monthlyPayment,
      interestRate: l.interestRate,
      notes: l.notes,
      createdAt: l.createdAt,
      updatedAt: l.updatedAt,
    )).toList();
  }

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
