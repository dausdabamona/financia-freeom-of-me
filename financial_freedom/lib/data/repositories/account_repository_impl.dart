import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/account.dart' as domain;
import 'package:financial_freedom/domain/repositories/account_repository.dart';

/// Implementation of AccountRepository using Drift database
class AccountRepositoryImpl implements AccountRepository {
  final AppDatabase _database;

  AccountRepositoryImpl(this._database);

  @override
  Future<Either<Failure, List<domain.Account>>> getAllAccounts() async {
    try {
      final dbAccounts = await _database.accountDao.getAllAccounts();
      return Right(dbAccounts.map(_toDomain).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get all accounts: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Account>> getAccountById(String id) async {
    try {
      final dbAccount = await _database.accountDao.getAccountById(int.parse(id));
      if (dbAccount == null) {
        return const Left(DatabaseFailure(message: 'Account not found'));
      }
      return Right(_toDomain(dbAccount));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get account: $e'));
    }
  }

  @override
  Future<Either<Failure, List<domain.Account>>> getLiquidAccounts() async {
    try {
      final dbAccounts = await _database.accountDao.getLiquidAccounts();
      return Right(dbAccounts.map(_toDomain).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get liquid accounts: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalLiquidBalance() async {
    try {
      final balance = await _database.accountDao.getTotalLiquidBalance();
      return Right(balance);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total liquid balance: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalBalance() async {
    try {
      final balance = await _database.accountDao.getTotalBalance();
      return Right(balance);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total balance: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAccount(domain.Account account) async {
    try {
      final companion = AccountsCompanion(
        name: Value(account.name),
        type: Value(account.type.code),
        balance: Value(account.balance),
        isLiquid: Value(account.isLiquid),
      );
      await _database.accountDao.insertAccount(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to save account: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAccount(domain.Account account) async {
    try {
      final dbAccount = Account(
        id: int.parse(account.id),
        name: account.name,
        type: account.type.code,
        balance: account.balance,
        isLiquid: account.isLiquid,
        createdAt: account.createdAt,
        updatedAt: DateTime.now(),
      );
      await _database.accountDao.updateAccount(dbAccount);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update account: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBalance(String accountId, double newBalance) async {
    try {
      await _database.accountDao.updateBalance(int.parse(accountId), newBalance);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update balance: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String accountId) async {
    try {
      await _database.accountDao.deleteAccount(int.parse(accountId));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete account: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<domain.Account>>> watchAllAccounts() {
    return _database.accountDao.watchAllAccounts().map((dbAccounts) {
      try {
        return Right<Failure, List<domain.Account>>(
          dbAccounts.map(_toDomain).toList(),
        );
      } catch (e) {
        return Left<Failure, List<domain.Account>>(
          DatabaseFailure(message: 'Failed to watch accounts: $e'),
        );
      }
    });
  }

  domain.Account _toDomain(Account dbAccount) {
    return domain.Account(
      id: dbAccount.id.toString(),
      name: dbAccount.name,
      type: domain.AccountType.fromCode(dbAccount.type),
      balance: dbAccount.balance,
      isLiquid: dbAccount.isLiquid,
      createdAt: dbAccount.createdAt,
      updatedAt: dbAccount.updatedAt,
    );
  }
}
