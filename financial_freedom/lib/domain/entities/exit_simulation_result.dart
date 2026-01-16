import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/exit_scenario.dart';
import 'package:financial_freedom/domain/entities/exit_insight.dart';
import 'package:financial_freedom/domain/entities/exit_zone.dart';
import 'package:financial_freedom/domain/entities/weekly_projection.dart';

/// Exit Simulation Result holds the complete output of a simulation run
/// for a specific scenario.
class ExitSimulationResult extends Equatable {
  final ExitScenario scenario;
  final List<WeeklyProjection> weeklyProjections;
  final ExitInsight insight;
  final DateTime simulatedAt;

  const ExitSimulationResult({
    required this.scenario,
    required this.weeklyProjections,
    required this.insight,
    required this.simulatedAt,
  });

  /// Get projections by zone
  List<WeeklyProjection> get safeWeeks =>
      weeklyProjections.where((w) => w.zone == ExitZone.safe).toList();

  List<WeeklyProjection> get warningWeeks =>
      weeklyProjections.where((w) => w.zone == ExitZone.warning).toList();

  List<WeeklyProjection> get criticalWeeks =>
      weeklyProjections.where((w) => w.zone == ExitZone.critical).toList();

  List<WeeklyProjection> get zeroWeeks =>
      weeklyProjections.where((w) => w.zone == ExitZone.zero).toList();

  /// Get the first week where each zone starts
  int? get firstWarningWeek {
    final week = weeklyProjections.cast<WeeklyProjection?>().firstWhere(
          (w) => w?.zone == ExitZone.warning,
          orElse: () => null,
        );
    return week?.weekNumber;
  }

  int? get firstCriticalWeek {
    final week = weeklyProjections.cast<WeeklyProjection?>().firstWhere(
          (w) => w?.zone == ExitZone.critical,
          orElse: () => null,
        );
    return week?.weekNumber;
  }

  int? get firstZeroWeek {
    final week = weeklyProjections.cast<WeeklyProjection?>().firstWhere(
          (w) => w?.zone == ExitZone.zero,
          orElse: () => null,
        );
    return week?.weekNumber;
  }

  /// Get key milestone weeks for display
  List<WeeklyProjection> get milestoneWeeks {
    final milestones = <WeeklyProjection>[];

    // Always include week 1
    if (weeklyProjections.isNotEmpty) {
      milestones.add(weeklyProjections.first);
    }

    // Include zone transition points
    ExitZone? lastZone;
    for (final week in weeklyProjections) {
      if (lastZone != null && week.zone != lastZone) {
        milestones.add(week);
      }
      lastZone = week.zone;
    }

    // Include quarterly milestones (13, 26, 39, 52 weeks)
    for (final milestone in [13, 26, 39, 52, 78, 104, 130, 156]) {
      if (milestone <= weeklyProjections.length) {
        final week = weeklyProjections[milestone - 1];
        if (!milestones.contains(week)) {
          milestones.add(week);
        }
      }
    }

    // Sort by week number
    milestones.sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

    return milestones;
  }

  /// Get summary for display
  String get summaryText {
    if (insight.maxRunwayWeeks >= 156) {
      return 'Runway lebih dari 3 tahun';
    } else if (insight.maxRunwayWeeks >= 52) {
      return 'Runway ${insight.maxRunwayMonths.toStringAsFixed(0)} bulan';
    } else {
      return 'Runway ${insight.maxRunwayWeeks} minggu';
    }
  }

  @override
  List<Object?> get props => [scenario, weeklyProjections, insight, simulatedAt];
}

/// Comparison between two simulation results
class SimulationComparison extends Equatable {
  final ExitSimulationResult baseline;
  final ExitSimulationResult alternative;

  const SimulationComparison({
    required this.baseline,
    required this.alternative,
  });

  /// Difference in weeks safe
  int get weeksSafeDifference =>
      alternative.insight.weeksSafe - baseline.insight.weeksSafe;

  /// Difference in weeks to critical
  int get weeksToCriticalDifference =>
      alternative.insight.weeksToCritical - baseline.insight.weeksToCritical;

  /// Difference in max runway
  int get runwayDifference =>
      alternative.insight.maxRunwayWeeks - baseline.insight.maxRunwayWeeks;

  /// Is the alternative better?
  bool get isAlternativeBetter => runwayDifference > 0;

  /// Generate comparison message
  String get comparisonMessage {
    if (runwayDifference <= 0) {
      return 'Skenario ini tidak memberikan perbaikan signifikan.';
    }

    if (runwayDifference >= 52) {
      return 'Skenario "${alternative.scenario.name}" menambah runway '
          '${(runwayDifference / 4.33).toStringAsFixed(0)} bulan. '
          'Perubahan besar dari satu keputusan.';
    }

    if (runwayDifference >= 26) {
      return 'Dengan "${alternative.scenario.name}", kamu mendapat '
          'tambahan ${runwayDifference} minggu sebelum zona kritis. '
          'Hampir setengah tahun tambahan.';
    }

    if (runwayDifference >= 12) {
      return '${alternative.scenario.name} menambah ${runwayDifference} minggu. '
          'Waktu yang cukup untuk memulai sesuatu yang baru.';
    }

    return 'Perubahan kecil ini menambah $runwayDifference minggu. '
        'Setiap minggu berarti.';
  }

  @override
  List<Object?> get props => [baseline, alternative];
}
