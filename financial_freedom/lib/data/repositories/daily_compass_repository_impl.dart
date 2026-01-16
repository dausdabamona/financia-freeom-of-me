import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/data/mappers/daily_compass_mapper.dart';
import 'package:financial_freedom/domain/entities/daily_compass_entry.dart';
import 'package:financial_freedom/domain/repositories/daily_compass_repository.dart';

/// Implementation of DailyCompassRepository using Drift database
class DailyCompassRepositoryImpl implements DailyCompassRepository {
  final AppDatabase _database;

  DailyCompassRepositoryImpl(this._database);

  @override
  Future<Either<Failure, DailyCompassEntry?>> getTodayCompass() async {
    try {
      final dbCompass = await _database.dailyCompassDao.getTodayCompass();
      if (dbCompass == null) {
        return const Right(null);
      }
      return Right(DailyCompassMapper.toDomain(dbCompass));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get today compass: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, DailyCompassEntry?>> getCompassForDate(
      DateTime date) async {
    try {
      final dbCompass = await _database.dailyCompassDao.getCompassForDate(date);
      if (dbCompass == null) {
        return const Right(null);
      }
      return Right(DailyCompassMapper.toDomain(dbCompass));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get compass for date: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, List<DailyCompassEntry>>> getAllCompassEntries() async {
    try {
      final dbEntries = await _database.dailyCompassDao.getAllCompassEntries();
      return Right(
        dbEntries.map(DailyCompassMapper.toDomain).toList(),
      );
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get all compass entries: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, List<DailyCompassEntry>>> getCompassEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final dbEntries = await _database.dailyCompassDao
          .getCompassEntriesByDateRange(startDate, endDate);
      return Right(
        dbEntries.map(DailyCompassMapper.toDomain).toList(),
      );
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get compass entries by date range: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, double>> getCompletionRate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final rate = await _database.dailyCompassDao
          .getCompletionRate(startDate, endDate);
      return Right(rate);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get completion rate: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveCompassEntry(
      DailyCompassEntry entry) async {
    try {
      final companion = DailyCompassMapper.toCompanion(entry);
      await _database.dailyCompassDao.upsertTodayCompass(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to save compass entry: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateCompassEntry(
      DailyCompassEntry entry) async {
    try {
      final dbModel = DailyCompassMapper.toDbModel(entry);
      await _database.dailyCompassDao.updateCompassEntry(dbModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update compass entry: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> markTodayCompleted({String? notes}) async {
    try {
      final todayCompass = await _database.dailyCompassDao.getTodayCompass();
      if (todayCompass != null) {
        await _database.dailyCompassDao.markCompleted(
          todayCompass.id,
          notes: notes,
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to mark today completed: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCompassEntry(String entryId) async {
    try {
      await _database.dailyCompassDao.deleteCompassEntry(int.parse(entryId));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to delete compass entry: $e',
      ));
    }
  }

  @override
  Stream<Either<Failure, DailyCompassEntry?>> watchTodayCompass() {
    return _database.dailyCompassDao.watchTodayCompass().map((dbCompass) {
      try {
        if (dbCompass == null) {
          return const Right<Failure, DailyCompassEntry?>(null);
        }
        return Right<Failure, DailyCompassEntry?>(
          DailyCompassMapper.toDomain(dbCompass),
        );
      } catch (e) {
        return Left<Failure, DailyCompassEntry?>(DatabaseFailure(
          message: 'Failed to watch today compass: $e',
        ));
      }
    });
  }
}
