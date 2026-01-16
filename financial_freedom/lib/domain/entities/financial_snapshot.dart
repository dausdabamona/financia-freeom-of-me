import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/freedom_phase.dart';

/// Represents a point-in-time financial snapshot.
///
/// This is the core entity of the Reality Engine.
/// It captures the financial truth at a specific moment.
///
/// Key metrics:
/// - Burn Rate: Monthly expenses (including debt payments and buffer)
/// - Runway: Months of survival without active income
/// - Salary Dependency: How much of income comes from salary
/// - Time Freedom Index: Free hours per week / 168
/// - Freedom Phase: Current stage in the journey
class FinancialSnapshot extends Equatable {
  final String id;
  final DateTime date;

  /// Monthly burn rate = essential + optional + debt payments + buffer
  final double burnRate;

  /// Runway in months = liquid assets / burn rate
  final double runwayMonths;

  /// Salary dependency ratio (0.0 - 1.0)
  /// 0.0 = fully passive/business income
  /// 1.0 = fully dependent on salary
  final double salaryDependencyRatio;

  /// Time freedom index (0.0 - 1.0)
  /// free_hours_per_week / 168
  final double timeFreedomIndex;

  /// Current freedom phase
  final FreedomPhase freedomPhase;

  /// Total liquid assets (can be accessed within days)
  final double totalLiquidAssets;

  /// Total passive income per month
  final double totalPassiveIncome;

  /// Total monthly income (all sources)
  final double totalMonthlyIncome;

  /// Net worth = assets - liabilities
  final double netWorth;

  const FinancialSnapshot({
    required this.id,
    required this.date,
    required this.burnRate,
    required this.runwayMonths,
    required this.salaryDependencyRatio,
    required this.timeFreedomIndex,
    required this.freedomPhase,
    required this.totalLiquidAssets,
    required this.totalPassiveIncome,
    required this.totalMonthlyIncome,
    required this.netWorth,
  });

  /// Runway in days
  double get runwayDays => runwayMonths * 30;

  /// Salary dependency as percentage (0-100)
  double get salaryDependencyPercent => salaryDependencyRatio * 100;

  /// Freedom score (inverse of salary dependency)
  double get freedomScore => 100 - salaryDependencyPercent;

  /// Is in danger zone (runway < 3 months)
  bool get isInDangerZone => runwayMonths < 3;

  /// Is in warning zone (runway < 6 months)
  bool get isInWarningZone => runwayMonths < 6;

  /// Can cover expenses with passive income
  bool get canLiveOnPassiveIncome => totalPassiveIncome >= burnRate;

  /// Get formatted runway string
  String get runwayFormatted {
    if (runwayMonths >= 12) {
      final years = (runwayMonths / 12).toStringAsFixed(1);
      return '$years tahun';
    } else {
      return '${runwayMonths.toStringAsFixed(1)} bulan';
    }
  }

  /// Get friendly message about current situation
  String get situationMessage {
    if (runwayMonths < 1) {
      return 'Kamu perlu dana darurat segera. Mari fokus di sini dulu.';
    } else if (runwayMonths < 3) {
      return 'Runway-mu pendek. Prioritas: kurangi pengeluaran atau tambah pemasukan.';
    } else if (runwayMonths < 6) {
      return 'Kamu aman ${runwayMonths.toStringAsFixed(1)} bulan. Terus bangun buffer-mu.';
    } else if (runwayMonths < 12) {
      return 'Kamu aman ${runwayMonths.toStringAsFixed(1)} bulan tanpa gaji. Fondasi bagus!';
    } else {
      return 'Runway-mu lebih dari setahun. Fokus membangun passive income.';
    }
  }

  @override
  List<Object?> get props => [
        id,
        date,
        burnRate,
        runwayMonths,
        salaryDependencyRatio,
        timeFreedomIndex,
        freedomPhase,
        totalLiquidAssets,
        totalPassiveIncome,
        totalMonthlyIncome,
        netWorth,
      ];
}
