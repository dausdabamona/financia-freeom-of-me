import 'package:uuid/uuid.dart';
import 'package:financial_freedom/domain/entities/exit_zone.dart';
import 'package:financial_freedom/domain/entities/exit_scenario.dart';
import 'package:financial_freedom/domain/entities/exit_insight.dart';
import 'package:financial_freedom/domain/entities/weekly_projection.dart';
import 'package:financial_freedom/domain/entities/exit_simulation_result.dart';

/// Weekly Exit Simulator - Core Engine for Life Freedom Simulation
///
/// Philosophy: This is not a financial calculator.
/// This is a Life Freedom Simulator answering one core question:
///
/// "Jika gaji berhenti hari ini, sampai minggu ke berapa aku benar-benar aman,
/// dan di mana titik rawan dimulai?"
///
/// Tone: Visioner, Menenangkan, Jujur
class WeeklyExitSimulator {
  static const int maxWeeks = 156; // 3 years
  static const double weeksPerMonth = 4.33;
  static const _uuid = Uuid();

  const WeeklyExitSimulator();

  /// Run simulation for a given scenario
  ///
  /// Inputs:
  /// - [liquidCash]: Current liquid cash and liquid assets
  /// - [monthlyBurnRate]: Monthly baseline expenses
  /// - [monthlyPassiveIncome]: Monthly passive income
  /// - [monthlyDebtPayments]: Monthly debt payments (included in burn if not separate)
  /// - [scenario]: The exit scenario with modifiers
  /// - [safetyBufferMultiplier]: How many weeks of burn to consider "safe" (default 3)
  ExitSimulationResult runSimulation({
    required double liquidCash,
    required double monthlyBurnRate,
    required double monthlyPassiveIncome,
    required double monthlyDebtPayments,
    required ExitScenario scenario,
    double safetyBufferMultiplier = 3.0,
  }) {
    // Convert monthly to weekly
    final baseWeeklyBurn = monthlyBurnRate / weeksPerMonth;
    final baseWeeklyIncome = monthlyPassiveIncome / weeksPerMonth;
    final weeklyDebt = monthlyDebtPayments / weeksPerMonth;

    // Apply scenario modifiers
    final weeklyBurn = baseWeeklyBurn * scenario.weeklyBurnModifier;
    final weeklyIncome = baseWeeklyIncome + scenario.weeklyIncomeModifier;

    // Calculate safety threshold
    final safetyThreshold = weeklyBurn * safetyBufferMultiplier;
    final warningThreshold = weeklyBurn;

    // Run week-by-week simulation
    final projections = <WeeklyProjection>[];
    double currentBalance = liquidCash;
    final now = DateTime.now();

    int? firstWarningWeek;
    int? firstCriticalWeek;
    int? firstZeroWeek;

    for (int week = 1; week <= maxWeeks; week++) {
      final startingBalance = currentBalance;
      final income = weeklyIncome;
      final expenses = weeklyBurn + weeklyDebt;
      final endingBalance = startingBalance + income - expenses;

      // Determine zone
      final zone = _determineZone(
        endingBalance,
        safetyThreshold,
        warningThreshold,
      );

      // Track zone transitions
      if (zone == ExitZone.warning && firstWarningWeek == null) {
        firstWarningWeek = week;
      }
      if (zone == ExitZone.critical && firstCriticalWeek == null) {
        firstCriticalWeek = week;
      }
      if (zone == ExitZone.zero && firstZeroWeek == null) {
        firstZeroWeek = week;
      }

      projections.add(WeeklyProjection(
        id: _uuid.v4(),
        scenarioId: scenario.id,
        weekNumber: week,
        startingBalance: startingBalance,
        income: income,
        expenses: expenses,
        endingBalance: endingBalance,
        zone: zone,
        createdAt: now,
      ));

      // Update balance for next week
      currentBalance = endingBalance;

      // Early exit if we've been at zero for a while
      if (zone == ExitZone.zero && week > (firstZeroWeek ?? week) + 12) {
        break;
      }
    }

    // Calculate weeks safe (until first non-safe zone)
    final weeksSafe = firstWarningWeek != null
        ? firstWarningWeek - 1
        : projections.length;

    // Calculate weeks to critical
    final weeksToCritical = firstCriticalWeek ?? projections.length;

    // Calculate weeks to zero
    final weeksToZero = firstZeroWeek ?? projections.length;

    // Max runway (last week with positive balance)
    final maxRunway = projections
        .lastWhere(
          (p) => p.endingBalance > 0,
          orElse: () => projections.first,
        )
        .weekNumber;

    // Current zone (week 1)
    final currentZone = projections.first.zone;

    // Create insight
    final insight = ExitInsight(
      scenarioId: scenario.id,
      scenarioName: scenario.name,
      weeksSafe: weeksSafe,
      weeksToCritical: weeksToCritical,
      weeksToZero: weeksToZero,
      maxRunwayWeeks: maxRunway,
      currentZone: currentZone,
    );

    return ExitSimulationResult(
      scenario: scenario,
      weeklyProjections: projections,
      insight: insight,
      simulatedAt: now,
    );
  }

  /// Run simulation and compare with baseline
  ExitSimulationResult runSimulationWithComparison({
    required double liquidCash,
    required double monthlyBurnRate,
    required double monthlyPassiveIncome,
    required double monthlyDebtPayments,
    required ExitScenario scenario,
    required ExitSimulationResult? baselineResult,
    double safetyBufferMultiplier = 3.0,
  }) {
    final result = runSimulation(
      liquidCash: liquidCash,
      monthlyBurnRate: monthlyBurnRate,
      monthlyPassiveIncome: monthlyPassiveIncome,
      monthlyDebtPayments: monthlyDebtPayments,
      scenario: scenario,
      safetyBufferMultiplier: safetyBufferMultiplier,
    );

    // If we have a baseline to compare, calculate weeks gained
    if (baselineResult != null && !scenario.isBaseline) {
      final weeksGained =
          result.insight.weeksSafe - baselineResult.insight.weeksSafe;

      // Create updated insight with comparison
      final insightWithComparison = ExitInsight(
        scenarioId: result.insight.scenarioId,
        scenarioName: result.insight.scenarioName,
        weeksSafe: result.insight.weeksSafe,
        weeksToCritical: result.insight.weeksToCritical,
        weeksToZero: result.insight.weeksToZero,
        maxRunwayWeeks: result.insight.maxRunwayWeeks,
        currentZone: result.insight.currentZone,
        weeksGainedVsBaseline: weeksGained,
      );

      return ExitSimulationResult(
        scenario: result.scenario,
        weeklyProjections: result.weeklyProjections,
        insight: insightWithComparison,
        simulatedAt: result.simulatedAt,
      );
    }

    return result;
  }

  /// Determine the zone based on ending balance and thresholds
  ExitZone _determineZone(
    double endingBalance,
    double safetyThreshold,
    double warningThreshold,
  ) {
    if (endingBalance <= 0) {
      return ExitZone.zero;
    }
    if (endingBalance < warningThreshold) {
      return ExitZone.critical;
    }
    if (endingBalance < safetyThreshold) {
      return ExitZone.warning;
    }
    return ExitZone.safe;
  }

  /// Calculate quick summary without full simulation
  /// Useful for quick preview/estimation
  Map<String, dynamic> quickEstimate({
    required double liquidCash,
    required double monthlyBurnRate,
    required double monthlyPassiveIncome,
  }) {
    final weeklyBurn = monthlyBurnRate / weeksPerMonth;
    final weeklyIncome = monthlyPassiveIncome / weeksPerMonth;
    final weeklyNet = weeklyIncome - weeklyBurn;

    if (weeklyNet >= 0) {
      // Sustainable - won't run out
      return {
        'sustainable': true,
        'weeksToZero': maxWeeks,
        'message': 'Penghasilan pasifmu sudah menutupi pengeluaran.',
      };
    }

    // Calculate weeks until zero
    final weeksToZero = (liquidCash / weeklyNet.abs()).ceil();

    return {
      'sustainable': false,
      'weeksToZero': weeksToZero,
      'message': 'Estimasi runway: $weeksToZero minggu',
    };
  }
}
