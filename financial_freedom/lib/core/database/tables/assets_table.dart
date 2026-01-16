import 'package:drift/drift.dart';

/// Assets table - tracks owned assets that have value
///
/// Includes both liquid (can sell quickly) and illiquid assets.
/// Also tracks if asset produces passive income.
///
/// Examples:
/// - Property (illiquid, may produce rental income)
/// - Stocks/Mutual Funds (liquid, may produce dividends)
/// - Gold (liquid)
/// - Vehicle (illiquid, no income)
/// - Business equity (illiquid, may produce income)
class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get liquidValue => real().withDefault(const Constant(0.0))();
  BoolColumn get producesIncome => boolean().withDefault(const Constant(false))();
  RealColumn get monthlyIncome => real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
