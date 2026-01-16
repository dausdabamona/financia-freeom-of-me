import 'package:drift/drift.dart';

/// Monthly Baseline table - tracks expected monthly costs
///
/// This is the "baseline" - what you expect to spend each month.
/// Updated periodically as life circumstances change.
///
/// Components:
/// - Essential costs: Housing, food, utilities, healthcare
/// - Optional costs: Entertainment, dining out, subscriptions
/// - Safety buffer: Emergency/unexpected expenses reserve
class MonthlyBaselines extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Format: YYYY-MM (e.g., "2024-01")
  TextColumn get month => text().withLength(min: 7, max: 7).unique()();

  /// Essential living costs (needs)
  RealColumn get essentialCost => real().withDefault(const Constant(0.0))();

  /// Optional lifestyle costs (wants)
  RealColumn get optionalCost => real().withDefault(const Constant(0.0))();

  /// Safety buffer for unexpected expenses
  RealColumn get safetyBuffer => real().withDefault(const Constant(0.0))();

  /// Notes about this month's baseline
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
