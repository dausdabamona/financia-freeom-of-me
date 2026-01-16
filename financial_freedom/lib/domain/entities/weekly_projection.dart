import 'package:equatable/equatable.dart';
import 'package:financial_freedom/domain/entities/exit_zone.dart';

/// Weekly Projection represents the financial state for a single week
/// in the exit simulation.
///
/// Each week tells a story of your journey towards or away from freedom.
class WeeklyProjection extends Equatable {
  final String id;
  final String scenarioId;
  final int weekNumber;
  final double startingBalance;
  final double income;
  final double expenses;
  final double endingBalance;
  final ExitZone zone;
  final DateTime createdAt;

  const WeeklyProjection({
    required this.id,
    required this.scenarioId,
    required this.weekNumber,
    required this.startingBalance,
    required this.income,
    required this.expenses,
    required this.endingBalance,
    required this.zone,
    required this.createdAt,
  });

  /// Net change for this week
  double get netChange => income - expenses;

  /// Is this week in a danger zone?
  bool get isDangerous => zone == ExitZone.critical || zone == ExitZone.zero;

  /// Is this week safe?
  bool get isSafe => zone == ExitZone.safe;

  /// Format ending balance for display
  String get endingBalanceFormatted {
    if (endingBalance >= 1000000000) {
      return 'Rp ${(endingBalance / 1000000000).toStringAsFixed(1)}M';
    } else if (endingBalance >= 1000000) {
      return 'Rp ${(endingBalance / 1000000).toStringAsFixed(1)}Jt';
    } else if (endingBalance >= 1000) {
      return 'Rp ${(endingBalance / 1000).toStringAsFixed(1)}Rb';
    } else if (endingBalance < 0) {
      return '-Rp ${(endingBalance.abs()).toStringAsFixed(0)}';
    }
    return 'Rp ${endingBalance.toStringAsFixed(0)}';
  }

  /// Week label (e.g., "Minggu 1", "Minggu 52")
  String get weekLabel => 'Minggu $weekNumber';

  /// Approximate month (for longer timelines)
  int get approximateMonth => (weekNumber / 4.33).ceil();

  @override
  List<Object?> get props => [
        id,
        scenarioId,
        weekNumber,
        startingBalance,
        income,
        expenses,
        endingBalance,
        zone,
        createdAt,
      ];

  WeeklyProjection copyWith({
    String? id,
    String? scenarioId,
    int? weekNumber,
    double? startingBalance,
    double? income,
    double? expenses,
    double? endingBalance,
    ExitZone? zone,
    DateTime? createdAt,
  }) {
    return WeeklyProjection(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      weekNumber: weekNumber ?? this.weekNumber,
      startingBalance: startingBalance ?? this.startingBalance,
      income: income ?? this.income,
      expenses: expenses ?? this.expenses,
      endingBalance: endingBalance ?? this.endingBalance,
      zone: zone ?? this.zone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
