import 'package:drift/drift.dart';

/// Account types for financial tracking
class AccountType {
  static const String cash = 'cash';
  static const String bank = 'bank';
  static const String ewallet = 'ewallet';
  static const String investment = 'investment';

  static const List<String> values = [cash, bank, ewallet, investment];
}

/// Accounts table - tracks where money is stored
///
/// Examples:
/// - Cash in wallet
/// - Bank accounts (savings, checking)
/// - E-wallets (GoPay, OVO, Dana)
/// - Investment accounts (stocks, mutual funds)
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text().withLength(min: 1, max: 20)();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  BoolColumn get isLiquid => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
