import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/transaction.dart';

/// Repository contract for transaction operations.
abstract class TransactionRepository {
  /// Get all transactions
  Future<Either<Failure, List<Transaction>>> getAllTransactions();

  /// Get transaction by id
  Future<Either<Failure, Transaction>> getTransactionById(String id);

  /// Get transactions within a date range
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get transactions for a specific month (YYYY-MM)
  Future<Either<Failure, List<Transaction>>> getTransactionsForMonth(String month);

  /// Get total income for a month
  Future<Either<Failure, double>> getTotalIncomeForMonth(String month);

  /// Get total expenses for a month
  Future<Either<Failure, double>> getTotalExpensesForMonth(String month);

  /// Get salary income for a month
  Future<Either<Failure, double>> getSalaryIncomeForMonth(String month);

  /// Get passive income for a month (investment, rental, etc.)
  Future<Either<Failure, double>> getPassiveIncomeForMonth(String month);

  /// Save a new transaction
  Future<Either<Failure, void>> saveTransaction(Transaction transaction);

  /// Update an existing transaction
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);

  /// Delete a transaction
  Future<Either<Failure, void>> deleteTransaction(String transactionId);

  /// Watch transactions for a specific month
  Stream<Either<Failure, List<Transaction>>> watchTransactionsForMonth(String month);
}
