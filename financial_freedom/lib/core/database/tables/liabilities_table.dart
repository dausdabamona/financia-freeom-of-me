import 'package:drift/drift.dart';

/// Liabilities table - tracks debts and obligations
///
/// Examples:
/// - Mortgage
/// - Car loan
/// - Credit card debt
/// - Personal loans
/// - Student loans
class Liabilities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get remainingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get monthlyPayment => real().withDefault(const Constant(0.0))();
  RealColumn get interestRate => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
