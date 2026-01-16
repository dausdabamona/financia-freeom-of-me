import 'package:financial_freedom/domain/entities/freedom_phase.dart';
import 'package:financial_freedom/domain/entities/focus_domain.dart';
import 'package:financial_freedom/domain/entities/financial_snapshot.dart';
import 'package:financial_freedom/domain/entities/daily_compass_entry.dart';

/// Financial data used for calculations
class FinancialData {
  /// Monthly baseline costs
  final double essentialCost;
  final double optionalCost;
  final double safetyBuffer;

  /// Monthly debt payments from liabilities
  final double totalDebtPayments;

  /// Total liquid assets (accounts + liquid asset value)
  final double totalLiquidAssets;

  /// Income data for current month
  final double totalMonthlyIncome;
  final double salaryIncome;
  final double passiveIncome;

  /// Asset data
  final double totalAssetValue;
  final double assetPassiveIncome;

  /// Liability data
  final double totalLiabilities;

  /// Time data (optional, default to 0.3 for now)
  final double freeHoursPerWeek;

  const FinancialData({
    required this.essentialCost,
    required this.optionalCost,
    required this.safetyBuffer,
    required this.totalDebtPayments,
    required this.totalLiquidAssets,
    required this.totalMonthlyIncome,
    required this.salaryIncome,
    required this.passiveIncome,
    required this.totalAssetValue,
    required this.assetPassiveIncome,
    required this.totalLiabilities,
    this.freeHoursPerWeek = 50.4, // Default: 30% free time (168 * 0.3)
  });

  /// Create empty data for new users
  factory FinancialData.empty() {
    return const FinancialData(
      essentialCost: 0,
      optionalCost: 0,
      safetyBuffer: 0,
      totalDebtPayments: 0,
      totalLiquidAssets: 0,
      totalMonthlyIncome: 0,
      salaryIncome: 0,
      passiveIncome: 0,
      totalAssetValue: 0,
      assetPassiveIncome: 0,
      totalLiabilities: 0,
    );
  }
}

/// FreedomCalculator - Core calculation engine for financial metrics
///
/// This is the heart of the Reality Engine.
/// All financial truth calculations happen here.
class FreedomCalculator {
  const FreedomCalculator();

  /// Calculate monthly burn rate
  ///
  /// Formula: essential_cost + optional_cost + debt_payments + safety_buffer
  double calculateBurnRate(FinancialData data) {
    final burnRate = data.essentialCost +
        data.optionalCost +
        data.totalDebtPayments +
        data.safetyBuffer;

    // Minimum burn rate is 0
    return burnRate < 0 ? 0 : burnRate;
  }

  /// Calculate runway in months
  ///
  /// Formula: total_liquid_assets / burn_rate
  /// Returns infinity if burn rate is 0 (no expenses)
  double calculateRunwayMonths(FinancialData data) {
    final burnRate = calculateBurnRate(data);

    if (burnRate <= 0) {
      return double.infinity;
    }

    return data.totalLiquidAssets / burnRate;
  }

  /// Calculate salary dependency ratio (0.0 - 1.0)
  ///
  /// Formula: salary_income / total_monthly_income
  /// 0.0 = fully passive/business income
  /// 1.0 = fully dependent on salary
  double calculateSalaryDependencyRatio(FinancialData data) {
    if (data.totalMonthlyIncome <= 0) {
      // No income = fully dependent (need salary to survive)
      return 1.0;
    }

    final ratio = data.salaryIncome / data.totalMonthlyIncome;

    // Clamp between 0 and 1
    return ratio.clamp(0.0, 1.0);
  }

  /// Calculate time freedom index (0.0 - 1.0)
  ///
  /// Formula: free_hours_per_week / 168 (total hours in a week)
  double calculateTimeFreedomIndex(FinancialData data) {
    const totalHoursPerWeek = 168.0;
    final index = data.freeHoursPerWeek / totalHoursPerWeek;

    // Clamp between 0 and 1
    return index.clamp(0.0, 1.0);
  }

  /// Calculate total passive income
  ///
  /// Includes: investment returns, rental income, asset income
  double calculateTotalPassiveIncome(FinancialData data) {
    return data.passiveIncome + data.assetPassiveIncome;
  }

  /// Calculate net worth
  ///
  /// Formula: total_assets - total_liabilities
  double calculateNetWorth(FinancialData data) {
    final totalAssets = data.totalLiquidAssets + data.totalAssetValue;
    return totalAssets - data.totalLiabilities;
  }

  /// Determine freedom phase based on financial metrics
  ///
  /// Rules:
  /// - FREE: passive_income >= burn_rate AND time_freedom_index > 0.5
  /// - OPTIONAL: passive_income >= burn_rate
  /// - INDEPENDENT: runway > 18 AND salary_dependency < 0.3
  /// - TRANSITION: runway 6-18 AND salary_dependency 0.3-0.7
  /// - BOUND: runway < 6 OR salary_dependency > 0.7
  FreedomPhase determineFreedomPhase(FinancialData data) {
    final burnRate = calculateBurnRate(data);
    final runwayMonths = calculateRunwayMonths(data);
    final salaryDependency = calculateSalaryDependencyRatio(data);
    final timeFreedom = calculateTimeFreedomIndex(data);
    final passiveIncome = calculateTotalPassiveIncome(data);

    // Check from highest phase to lowest

    // FREE: Passive income covers expenses AND have time freedom
    if (passiveIncome >= burnRate && timeFreedom > 0.5) {
      return FreedomPhase.free;
    }

    // OPTIONAL: Passive income covers expenses (work is optional)
    if (passiveIncome >= burnRate) {
      return FreedomPhase.optional;
    }

    // INDEPENDENT: Long runway AND low salary dependency
    if (runwayMonths > 18 && salaryDependency < 0.3) {
      return FreedomPhase.independent;
    }

    // TRANSITION: Medium runway AND medium dependency
    if (runwayMonths >= 6 && runwayMonths <= 18 && salaryDependency <= 0.7) {
      return FreedomPhase.transition;
    }

    // BOUND: Short runway OR high dependency
    return FreedomPhase.bound;
  }

  /// Determine focus domain for daily compass
  ///
  /// Priority rules:
  /// 1. If runway < 6 OR salary_dependency > 70% → A_FINANCIAL
  /// 2. If emotional_pressure_high → C_PSYCHOLOGICAL (stub for future)
  /// 3. Else → B_TIME_SYSTEM
  FocusDomain determineFocusDomain(FinancialData data, {bool emotionalPressureHigh = false}) {
    final runwayMonths = calculateRunwayMonths(data);
    final salaryDependency = calculateSalaryDependencyRatio(data);

    // Priority 1: Financial urgency
    if (runwayMonths < 6 || salaryDependency > 0.7) {
      return FocusDomain.aFinancial;
    }

    // Priority 2: Emotional/psychological needs
    if (emotionalPressureHigh) {
      return FocusDomain.cPsychological;
    }

    // Priority 3: Build systems and time freedom
    return FocusDomain.bTimeSystem;
  }

  /// Generate a complete financial snapshot
  FinancialSnapshot generateSnapshot({
    required String id,
    required DateTime date,
    required FinancialData data,
  }) {
    return FinancialSnapshot(
      id: id,
      date: date,
      burnRate: calculateBurnRate(data),
      runwayMonths: calculateRunwayMonths(data),
      salaryDependencyRatio: calculateSalaryDependencyRatio(data),
      timeFreedomIndex: calculateTimeFreedomIndex(data),
      freedomPhase: determineFreedomPhase(data),
      totalLiquidAssets: data.totalLiquidAssets,
      totalPassiveIncome: calculateTotalPassiveIncome(data),
      totalMonthlyIncome: data.totalMonthlyIncome,
      netWorth: calculateNetWorth(data),
    );
  }

  /// Generate daily compass entry based on current situation
  DailyCompassEntry generateCompassEntry({
    required String id,
    required DateTime date,
    required FinancialData data,
    bool emotionalPressureHigh = false,
  }) {
    final focusDomain = determineFocusDomain(
      data,
      emotionalPressureHigh: emotionalPressureHigh,
    );

    final message = CompassMessages.getMessageFor(
      domain: focusDomain,
      runwayMonths: calculateRunwayMonths(data),
      salaryDependencyRatio: calculateSalaryDependencyRatio(data),
    );

    return DailyCompassEntry(
      id: id,
      date: date,
      focusDomain: focusDomain,
      message: message,
    );
  }
}
