import 'package:equatable/equatable.dart';

/// Represents a point-in-time financial snapshot.
///
/// This is a domain entity - it's pure Dart with no dependencies
/// on external packages (except Equatable for value equality).
///
/// Used to calculate:
/// - Burn Rate: Monthly expenses / 30 days
/// - Runway: Total liquid assets / monthly burn rate
/// - Salary Dependency: (Salary / Total Income) * 100%
class FinancialSnapshot extends Equatable {
  final String id;
  final DateTime date;
  final double totalIncome;
  final double salaryIncome;
  final double passiveIncome;
  final double totalExpenses;
  final double liquidAssets;
  final double totalAssets;
  final double totalLiabilities;

  const FinancialSnapshot({
    required this.id,
    required this.date,
    required this.totalIncome,
    required this.salaryIncome,
    required this.passiveIncome,
    required this.totalExpenses,
    required this.liquidAssets,
    required this.totalAssets,
    required this.totalLiabilities,
  });

  /// Net worth = Total Assets - Total Liabilities
  double get netWorth => totalAssets - totalLiabilities;

  /// Daily burn rate = Total Expenses / 30
  double get dailyBurnRate => totalExpenses / 30;

  /// Monthly burn rate (same as total expenses for simplicity)
  double get monthlyBurnRate => totalExpenses;

  /// Runway in months = Liquid Assets / Monthly Burn Rate
  /// Returns infinity if no expenses (financially free!)
  double get runwayMonths {
    if (monthlyBurnRate <= 0) return double.infinity;
    return liquidAssets / monthlyBurnRate;
  }

  /// Runway in days = Liquid Assets / Daily Burn Rate
  double get runwayDays {
    if (dailyBurnRate <= 0) return double.infinity;
    return liquidAssets / dailyBurnRate;
  }

  /// Salary dependency percentage (0-100)
  /// 0% = Fully independent (passive income covers everything)
  /// 100% = Fully dependent on salary
  double get salaryDependencyPercent {
    if (totalIncome <= 0) return 100.0;
    return (salaryIncome / totalIncome) * 100;
  }

  /// Freedom score (inverse of salary dependency)
  /// 100% = Fully free
  /// 0% = Fully dependent
  double get freedomScore => 100 - salaryDependencyPercent;

  @override
  List<Object?> get props => [
        id,
        date,
        totalIncome,
        salaryIncome,
        passiveIncome,
        totalExpenses,
        liquidAssets,
        totalAssets,
        totalLiabilities,
      ];
}
