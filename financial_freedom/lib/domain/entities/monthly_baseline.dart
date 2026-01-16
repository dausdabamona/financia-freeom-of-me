import 'package:equatable/equatable.dart';

/// Monthly Baseline entity - expected monthly costs
///
/// This is the baseline - what you expect to spend each month.
/// Used to calculate burn rate.
class MonthlyBaseline extends Equatable {
  final String id;

  /// Format: YYYY-MM (e.g., "2024-01")
  final String month;

  /// Essential living costs (needs)
  final double essentialCost;

  /// Optional lifestyle costs (wants)
  final double optionalCost;

  /// Safety buffer for unexpected expenses
  final double safetyBuffer;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MonthlyBaseline({
    required this.id,
    required this.month,
    required this.essentialCost,
    required this.optionalCost,
    required this.safetyBuffer,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total baseline cost (without debt payments)
  double get totalBaseline => essentialCost + optionalCost + safetyBuffer;

  /// Parse month string to DateTime (first day of month)
  DateTime get monthDate {
    final parts = month.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  @override
  List<Object?> get props => [
        id,
        month,
        essentialCost,
        optionalCost,
        safetyBuffer,
        notes,
        createdAt,
        updatedAt,
      ];
}
