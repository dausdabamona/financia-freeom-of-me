import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/account.dart';

/// Repository contract for account operations.
abstract class AccountRepository {
  /// Get all accounts
  Future<Either<Failure, List<Account>>> getAllAccounts();

  /// Get account by id
  Future<Either<Failure, Account>> getAccountById(String id);

  /// Get only liquid accounts (cash, bank, ewallet)
  Future<Either<Failure, List<Account>>> getLiquidAccounts();

  /// Get total balance of all liquid accounts
  Future<Either<Failure, double>> getTotalLiquidBalance();

  /// Get total balance of all accounts
  Future<Either<Failure, double>> getTotalBalance();

  /// Save a new account
  Future<Either<Failure, void>> saveAccount(Account account);

  /// Update an existing account
  Future<Either<Failure, void>> updateAccount(Account account);

  /// Update account balance
  Future<Either<Failure, void>> updateBalance(String accountId, double newBalance);

  /// Delete an account
  Future<Either<Failure, void>> deleteAccount(String accountId);

  /// Watch all accounts for changes
  Stream<Either<Failure, List<Account>>> watchAllAccounts();
}
