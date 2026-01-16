import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/time_profile.dart';

/// Repository contract for time profile operations.
///
/// "Dari 168 jam hidupmu setiap minggu, berapa yang benar-benar milikmu?"
abstract class TimeProfileRepository {
  /// Get the latest time profile
  Future<Either<Failure, TimeProfile?>> getLatestProfile();

  /// Get all time profiles
  Future<Either<Failure, List<TimeProfile>>> getAllProfiles();

  /// Save a new time profile
  Future<Either<Failure, void>> saveProfile(TimeProfile profile);

  /// Update an existing time profile
  Future<Either<Failure, void>> updateProfile(TimeProfile profile);

  /// Delete a time profile
  Future<Either<Failure, void>> deleteProfile(String profileId);

  /// Watch the latest time profile for changes
  Stream<Either<Failure, TimeProfile?>> watchLatestProfile();
}
