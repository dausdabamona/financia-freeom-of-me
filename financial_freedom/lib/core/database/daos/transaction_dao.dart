import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/database/tables/transactions_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  /// Get all transactions
  Future<List<TransactionEntry>> getAllTransactions() =>
      select(transactions).get();

  /// Get transaction by id
  Future<TransactionEntry?> getTransactionById(int id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get transactions within a date range
  Future<List<TransactionEntry>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(startDate) &
              t.date.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Get transactions for a specific month (YYYY-MM format)
  Future<List<TransactionEntry>> getTransactionsForMonth(String month) async {
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final monthNum = int.parse(parts[1]);

    final startDate = DateTime(year, monthNum, 1);
    final endDate = DateTime(year, monthNum + 1, 0, 23, 59, 59);

    return getTransactionsByDateRange(startDate, endDate);
  }

  /// Get total income for a month
  Future<double> getTotalIncomeForMonth(String month) async {
    final transactions = await getTransactionsForMonth(month);
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Get total expenses for a month
  Future<double> getTotalExpensesForMonth(String month) async {
    final transactions = await getTransactionsForMonth(month);
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Get salary income for a month
  Future<double> getSalaryIncomeForMonth(String month) async {
    final transactions = await getTransactionsForMonth(month);
    return transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.category == IncomeCategory.salary)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Get passive income for a month
  Future<double> getPassiveIncomeForMonth(String month) async {
    final transactions = await getTransactionsForMonth(month);
    return transactions
        .where((t) =>
            t.type == TransactionType.income &&
            IncomeCategory.passiveCategories.contains(t.category))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Get essential expenses for a month
  Future<double> getEssentialExpensesForMonth(String month) async {
    final transactions = await getTransactionsForMonth(month);
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            ExpenseCategory.essentialCategories.contains(t.category))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Get optional expenses for a month
  Future<double> getOptionalExpensesForMonth(String month) async {
    final transactions = await getTransactionsForMonth(month);
    return transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            ExpenseCategory.optionalCategories.contains(t.category))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Insert a new transaction
  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  /// Update a transaction
  Future<bool> updateTransaction(TransactionEntry transaction) {
    return update(transactions).replace(transaction);
  }

  /// Delete a transaction
  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Watch transactions for a specific month
  Stream<List<TransactionEntry>> watchTransactionsForMonth(String month) {
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final monthNum = int.parse(parts[1]);

    final startDate = DateTime(year, monthNum, 1);
    final endDate = DateTime(year, monthNum + 1, 0, 23, 59, 59);

    return (select(transactions)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(startDate) &
              t.date.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }
}
