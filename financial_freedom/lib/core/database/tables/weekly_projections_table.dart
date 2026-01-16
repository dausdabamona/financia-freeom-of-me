import 'package:drift/drift.dart';

/// Drift table definition for weekly exit projections
///
/// Each row represents one week in the exit simulation timeline.
class WeeklyProjectionsTable extends Table {
  @override
  String get tableName => 'weekly_exit_projection';

  /// Unique identifier
  TextColumn get id => text()();

  /// Reference to the scenario this projection belongs to
  TextColumn get scenarioId => text()();

  /// Week number (1-156 for 3 years)
  IntColumn get weekNumber => integer()();

  /// Balance at the start of this week
  RealColumn get startingBalance => real()();

  /// Income received during this week
  RealColumn get income => real()();

  /// Expenses during this week
  RealColumn get expenses => real()();

  /// Balance at the end of this week
  RealColumn get endingBalance => real()();

  /// Zone classification: SAFE, WARNING, CRITICAL, ZERO
  TextColumn get zone => text()();

  /// When this projection was created
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
