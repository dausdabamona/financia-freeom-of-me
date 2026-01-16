import 'package:drift/drift.dart';

/// Drift table definition for exit scenarios
///
/// Each scenario represents a "What If" situation for the exit simulation.
class ExitScenariosTable extends Table {
  @override
  String get tableName => 'exit_scenarios';

  /// Unique identifier
  TextColumn get id => text()();

  /// Scenario name (e.g., "Tanpa Gaji", "Biaya Turun 10%")
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Description of the scenario
  TextColumn get description => text().withLength(max: 500)();

  /// Multiplier for weekly burn rate (1.0 = no change, 0.9 = 10% reduction)
  RealColumn get weeklyBurnModifier => real().withDefault(const Constant(1.0))();

  /// Addition to weekly income (absolute amount)
  RealColumn get weeklyIncomeModifier => real().withDefault(const Constant(0.0))();

  /// One-time debt reduction amount
  RealColumn get debtReductionAmount => real().withDefault(const Constant(0.0))();

  /// Is this a default/system scenario?
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Is this the baseline scenario (no changes)?
  BoolColumn get isBaseline => boolean().withDefault(const Constant(false))();

  /// When the scenario was created
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
