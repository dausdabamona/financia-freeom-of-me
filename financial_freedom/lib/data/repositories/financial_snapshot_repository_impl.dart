import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/database/app_database.dart' hide FinancialSnapshot;
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/data/mappers/financial_snapshot_mapper.dart';
import 'package:financial_freedom/domain/entities/financial_snapshot.dart';
import 'package:financial_freedom/domain/repositories/financial_repository.dart';

/// Implementation of FinancialSnapshotRepository using Drift database
class FinancialSnapshotRepositoryImpl implements FinancialSnapshotRepository {
  final AppDatabase _database;

  FinancialSnapshotRepositoryImpl(this._database);

  @override
  Future<Either<Failure, FinancialSnapshot?>> getLatestSnapshot() async {
    try {
      final dbSnapshot =
          await _database.financialSnapshotDao.getLatestSnapshot();
      if (dbSnapshot == null) {
        return const Right(null);
      }
      return Right(FinancialSnapshotMapper.toDomain(dbSnapshot));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get latest snapshot: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, FinancialSnapshot?>> getTodaySnapshot() async {
    try {
      final dbSnapshot =
          await _database.financialSnapshotDao.getTodaySnapshot();
      if (dbSnapshot == null) {
        return const Right(null);
      }
      return Right(FinancialSnapshotMapper.toDomain(dbSnapshot));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get today snapshot: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, List<FinancialSnapshot>>> getAllSnapshots() async {
    try {
      final dbSnapshots =
          await _database.financialSnapshotDao.getAllSnapshots();
      return Right(
        dbSnapshots.map(FinancialSnapshotMapper.toDomain).toList(),
      );
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get all snapshots: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, List<FinancialSnapshot>>> getSnapshotsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final dbSnapshots = await _database.financialSnapshotDao
          .getSnapshotsByDateRange(startDate, endDate);
      return Right(
        dbSnapshots.map(FinancialSnapshotMapper.toDomain).toList(),
      );
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get snapshots by date range: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveSnapshot(FinancialSnapshot snapshot) async {
    try {
      final companion = FinancialSnapshotMapper.toCompanion(snapshot);
      await _database.financialSnapshotDao.upsertTodaySnapshot(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to save snapshot: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateSnapshot(
      FinancialSnapshot snapshot) async {
    try {
      final dbModel = FinancialSnapshotMapper.toDbModel(snapshot);
      await _database.financialSnapshotDao.updateSnapshot(dbModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update snapshot: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSnapshot(String snapshotId) async {
    try {
      await _database.financialSnapshotDao.deleteSnapshot(int.parse(snapshotId));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to delete snapshot: $e',
      ));
    }
  }

  @override
  Stream<Either<Failure, FinancialSnapshot?>> watchLatestSnapshot() {
    return _database.financialSnapshotDao.watchLatestSnapshot().map((dbSnapshot) {
      try {
        if (dbSnapshot == null) {
          return const Right<Failure, FinancialSnapshot?>(null);
        }
        return Right<Failure, FinancialSnapshot?>(
          FinancialSnapshotMapper.toDomain(dbSnapshot),
        );
      } catch (e) {
        return Left<Failure, FinancialSnapshot?>(DatabaseFailure(
          message: 'Failed to watch latest snapshot: $e',
        ));
      }
    });
  }

  @override
  Stream<Either<Failure, List<FinancialSnapshot>>> watchAllSnapshots() {
    return _database.financialSnapshotDao.watchAllSnapshots().map((dbSnapshots) {
      try {
        return Right<Failure, List<FinancialSnapshot>>(
          dbSnapshots.map(FinancialSnapshotMapper.toDomain).toList(),
        );
      } catch (e) {
        return Left<Failure, List<FinancialSnapshot>>(DatabaseFailure(
          message: 'Failed to watch all snapshots: $e',
        ));
      }
    });
  }
}
