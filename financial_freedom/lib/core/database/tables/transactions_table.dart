import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/tables/accounts_table.dart';

/// Transaction types
class TransactionType {
  static const String income = 'income';
  static const String expense = 'expense';

  static const List<String> values = [income, expense];
}

/// Income categories - source of money
class IncomeCategory {
  static const String salary = 'salary';
  static const String business = 'business';
  static const String investment = 'investment';
  static const String rental = 'rental';
  static const String freelance = 'freelance';
  static const String gift = 'gift';
  static const String other = 'other';

  /// Passive income sources (not tied to active work)
  static const List<String> passiveCategories = [
    investment,
    rental,
  ];

  static const List<String> values = [
    salary,
    business,
    investment,
    rental,
    freelance,
    gift,
    other,
  ];
}

/// Expense categories
class ExpenseCategory {
  // Essential (needs)
  static const String housing = 'housing';
  static const String utilities = 'utilities';
  static const String groceries = 'groceries';
  static const String transportation = 'transportation';
  static const String healthcare = 'healthcare';
  static const String insurance = 'insurance';
  static const String debtPayment = 'debt_payment';

  // Optional (wants)
  static const String dining = 'dining';
  static const String entertainment = 'entertainment';
  static const String shopping = 'shopping';
  static const String subscription = 'subscription';
  static const String travel = 'travel';
  static const String education = 'education';
  static const String other = 'other';

  /// Essential expenses - needed for survival
  static const List<String> essentialCategories = [
    housing,
    utilities,
    groceries,
    transportation,
    healthcare,
    insurance,
    debtPayment,
  ];

  /// Optional expenses - nice to have
  static const List<String> optionalCategories = [
    dining,
    entertainment,
    shopping,
    subscription,
    travel,
    education,
    other,
  ];

  static const List<String> values = [
    ...essentialCategories,
    ...optionalCategories,
  ];
}

/// Transactions table - records all money movements
///
/// Every income and expense is recorded here.
/// Used to calculate burn rate and income sources.
@DataClassName('TransactionEntry')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().withLength(min: 1, max: 255)();
  RealColumn get amount => real()();
  TextColumn get type => text().withLength(min: 1, max: 20)();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
