import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/monthly_baseline.dart' as domain;
import 'package:financial_freedom/domain/repositories/monthly_baseline_repository.dart';

/// Implementation of MonthlyBaselineRepository using Drift database
class MonthlyBaselineRepositoryImpl implements MonthlyBaselineRepository {
  final AppDatabase _database;

  MonthlyBaselineRepositoryImpl(this._database);

  @override
  Future<Either<Failure, List<domain.MonthlyBaseline>>> getAllBaselines() async {
    try {
      final dbBaselines = await _database.monthlyBaselineDao.getAllBaselines();
      return Right(dbBaselines.map(_toDomain).toList());
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get all baselines: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.MonthlyBaseline?>> getBaselineForMonth(String month) async {
    try {
      final dbBaseline = await _database.monthlyBaselineDao.getBaselineForMonth(month);
      if (dbBaseline == null) {
        return const Right(null);
      }
      return Right(_toDomain(dbBaseline));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get baseline for month: $e'));
    }
  }

  @override
  Future<Either<Failure, domain.MonthlyBaseline?>> getLatestBaseline() async {
    try {
      final dbBaseline = await _database.monthlyBaselineDao.getLatestBaseline();
      if (dbBaseline == null) {
        return const Right(null);
      }
      return Right(_toDomain(dbBaseline));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get latest baseline: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveBaseline(domain.MonthlyBaseline baseline) async {
    try {
      final companion = MonthlyBaselinesCompanion(
        month: Value(baseline.month),
        essentialCost: Value(baseline.essentialCost),
        optionalCost: Value(baseline.optionalCost),
        safetyBuffer: Value(baseline.safetyBuffer),
        notes: Value(baseline.notes),
      );
      await _database.monthlyBaselineDao.upsertBaseline(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to save baseline: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBaseline(String baselineId) async {
    try {
      await _database.monthlyBaselineDao.deleteBaseline(int.parse(baselineId));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete baseline: $e'));
    }
  }

  @override
  Stream<Either<Failure, domain.MonthlyBaseline?>> watchBaselineForMonth(String month) {
    return _database.monthlyBaselineDao.watchBaselineForMonth(month).map((dbBaseline) {
      try {
        if (dbBaseline == null) {
          return const Right<Failure, domain.MonthlyBaseline?>(null);
        }
        return Right<Failure, domain.MonthlyBaseline?>(_toDomain(dbBaseline));
      } catch (e) {
        return Left<Failure, domain.MonthlyBaseline?>(
          DatabaseFailure(message: 'Failed to watch baseline: $e'),
        );
      }
    });
  }

  domain.MonthlyBaseline _toDomain(MonthlyBaseline dbBaseline) {
    return domain.MonthlyBaseline(
      id: dbBaseline.id.toString(),
      month: dbBaseline.month,
      essentialCost: dbBaseline.essentialCost,
      optionalCost: dbBaseline.optionalCost,
      safetyBuffer: dbBaseline.safetyBuffer,
      notes: dbBaseline.notes,
      createdAt: dbBaseline.createdAt,
      updatedAt: dbBaseline.updatedAt,
    );
  }
}
