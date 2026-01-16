import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/financial_snapshot.dart';

/// Repository contract for financial snapshot operations.
///
/// This is defined in the domain layer as an abstract class.
/// The actual implementation lives in the data layer.
///
/// This follows the Dependency Inversion principle:
/// - Domain layer defines WHAT operations are needed
/// - Data layer defines HOW they are implemented
abstract class FinancialSnapshotRepository {
  /// Get the most recent financial snapshot
  Future<Either<Failure, FinancialSnapshot?>> getLatestSnapshot();

  /// Get snapshot for today (if exists)
  Future<Either<Failure, FinancialSnapshot?>> getTodaySnapshot();

  /// Get all snapshots for historical tracking
  Future<Either<Failure, List<FinancialSnapshot>>> getAllSnapshots();

  /// Get snapshots within a date range
  Future<Either<Failure, List<FinancialSnapshot>>> getSnapshotsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Save a new financial snapshot
  Future<Either<Failure, void>> saveSnapshot(FinancialSnapshot snapshot);

  /// Update an existing snapshot
  Future<Either<Failure, void>> updateSnapshot(FinancialSnapshot snapshot);

  /// Delete a snapshot
  Future<Either<Failure, void>> deleteSnapshot(String snapshotId);

  /// Watch the latest snapshot for real-time updates
  Stream<Either<Failure, FinancialSnapshot?>> watchLatestSnapshot();

  /// Watch all snapshots for real-time updates
  Stream<Either<Failure, List<FinancialSnapshot>>> watchAllSnapshots();
}
