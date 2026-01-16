import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/liability.dart' as domain;
import 'package:financial_freedom/domain/repositories/liability_repository.dart';

/// Implementation of LiabilityRepository using Drift database
class LiabilityRepositoryImpl implements LiabilityRepository {
  final AppDatabase _database;

  LiabilityRepositoryImpl(this._database);

  @override
  Future<Either<Failure, List<domain.Liability>>> getAllLiabilities() async {
    try {
      final dbLiabilities = await _database.liabilityDao.getAllLiabilities();
      return Right(dbLiabilities.map(_toDomain).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get all liabilities: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.Liability>> getLiabilityById(String id) async {
    try {
      final dbLiability = await _database.liabilityDao.getLiabilityById(int.parse(id));
      if (dbLiability == null) {
        return const Left(DatabaseFailure(message: 'Liability not found'));
      }
      return Right(_toDomain(dbLiability));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get liability: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalRemainingBalance() async {
    try {
      final balance = await _database.liabilityDao.getTotalRemainingBalance();
      return Right(balance);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total remaining balance: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalMonthlyPayment() async {
    try {
      final payment = await _database.liabilityDao.getTotalMonthlyPayment();
      return Right(payment);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total monthly payment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLiability(domain.Liability liability) async {
    try {
      final companion = LiabilitiesCompanion(
        name: Value(liability.name),
        remainingBalance: Value(liability.remainingBalance),
        monthlyPayment: Value(liability.monthlyPayment),
        interestRate: Value(liability.interestRate),
        notes: Value(liability.notes),
      );
      await _database.liabilityDao.insertLiability(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to save liability: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLiability(domain.Liability liability) async {
    try {
      final dbLiability = Liability(
        id: int.parse(liability.id),
        name: liability.name,
        remainingBalance: liability.remainingBalance,
        monthlyPayment: liability.monthlyPayment,
        interestRate: liability.interestRate,
        notes: liability.notes,
        createdAt: liability.createdAt,
        updatedAt: DateTime.now(),
      );
      await _database.liabilityDao.updateLiability(dbLiability);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update liability: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLiability(String liabilityId) async {
    try {
      await _database.liabilityDao.deleteLiability(int.parse(liabilityId));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete liability: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<domain.Liability>>> watchAllLiabilities() {
    return _database.liabilityDao.watchAllLiabilities().map((dbLiabilities) {
      try {
        return Right<Failure, List<domain.Liability>>(
          dbLiabilities.map(_toDomain).toList(),
        );
      } catch (e) {
        return Left<Failure, List<domain.Liability>>(
          DatabaseFailure(message: 'Failed to watch liabilities: $e'),
        );
      }
    });
  }

  domain.Liability _toDomain(Liability dbLiability) {
    return domain.Liability(
      id: dbLiability.id.toString(),
      name: dbLiability.name,
      remainingBalance: dbLiability.remainingBalance,
      monthlyPayment: dbLiability.monthlyPayment,
      interestRate: dbLiability.interestRate,
      notes: dbLiability.notes,
      createdAt: dbLiability.createdAt,
      updatedAt: dbLiability.updatedAt,
    );
  }
}
