import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:financial_freedom/core/database/app_database.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/time_profile.dart' as domain;
import 'package:financial_freedom/domain/repositories/time_profile_repository.dart';

/// Implementation of TimeProfileRepository using Drift database
class TimeProfileRepositoryImpl implements TimeProfileRepository {
  final AppDatabase _database;

  TimeProfileRepositoryImpl(this._database);

  @override
  Future<Either<Failure, domain.TimeProfile?>> getLatestProfile() async {
    try {
      final dbProfile = await _database.timeProfileDao.getLatestProfile();
      if (dbProfile == null) {
        return const Right(null);
      }
      return Right(_toDomain(dbProfile));
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get latest time profile: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, List<domain.TimeProfile>>> getAllProfiles() async {
    try {
      final dbProfiles = await _database.timeProfileDao.getAllProfiles();
      return Right(dbProfiles.map(_toDomain).toList());
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to get all time profiles: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveProfile(domain.TimeProfile profile) async {
    try {
      final companion = TimeProfilesCompanion(
        workHoursPerWeek: Value(profile.workHoursPerWeek),
        obligationHoursPerWeek: Value(profile.obligationHoursPerWeek),
        freeHoursPerWeek: Value(profile.freeHoursPerWeek),
      );
      await _database.timeProfileDao.insertProfile(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to save time profile: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(domain.TimeProfile profile) async {
    try {
      final dbProfile = TimeProfile(
        id: int.parse(profile.id),
        workHoursPerWeek: profile.workHoursPerWeek,
        obligationHoursPerWeek: profile.obligationHoursPerWeek,
        freeHoursPerWeek: profile.freeHoursPerWeek,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
      );
      await _database.timeProfileDao.updateProfile(dbProfile);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to update time profile: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile(String profileId) async {
    try {
      await _database.timeProfileDao.deleteProfile(int.parse(profileId));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        message: 'Failed to delete time profile: $e',
      ));
    }
  }

  @override
  Stream<Either<Failure, domain.TimeProfile?>> watchLatestProfile() {
    return _database.timeProfileDao.watchLatestProfile().map((dbProfile) {
      try {
        if (dbProfile == null) {
          return const Right<Failure, domain.TimeProfile?>(null);
        }
        return Right<Failure, domain.TimeProfile?>(_toDomain(dbProfile));
      } catch (e) {
        return Left<Failure, domain.TimeProfile?>(DatabaseFailure(
          message: 'Failed to watch time profile: $e',
        ));
      }
    });
  }

  domain.TimeProfile _toDomain(TimeProfile dbProfile) {
    return domain.TimeProfile(
      id: dbProfile.id.toString(),
      workHoursPerWeek: dbProfile.workHoursPerWeek,
      obligationHoursPerWeek: dbProfile.obligationHoursPerWeek,
      freeHoursPerWeek: dbProfile.freeHoursPerWeek,
      createdAt: dbProfile.createdAt,
      updatedAt: dbProfile.updatedAt,
    );
  }
}
