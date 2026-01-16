import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/daily_compass_entry.dart';

/// Repository contract for daily compass operations.
abstract class DailyCompassRepository {
  /// Get compass entry for today
  Future<Either<Failure, DailyCompassEntry?>> getTodayCompass();

  /// Get compass entry for a specific date
  Future<Either<Failure, DailyCompassEntry?>> getCompassForDate(DateTime date);

  /// Get all compass entries
  Future<Either<Failure, List<DailyCompassEntry>>> getAllCompassEntries();

  /// Get compass entries for date range
  Future<Either<Failure, List<DailyCompassEntry>>> getCompassEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get completion rate for a date range (completed / total)
  Future<Either<Failure, double>> getCompletionRate({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save a new compass entry
  Future<Either<Failure, void>> saveCompassEntry(DailyCompassEntry entry);

  /// Update compass entry (mainly for marking complete)
  Future<Either<Failure, void>> updateCompassEntry(DailyCompassEntry entry);

  /// Mark today's compass as completed
  Future<Either<Failure, void>> markTodayCompleted({String? notes});

  /// Delete a compass entry
  Future<Either<Failure, void>> deleteCompassEntry(String entryId);

  /// Watch today's compass for changes
  Stream<Either<Failure, DailyCompassEntry?>> watchTodayCompass();
}
