import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/monthly_baseline.dart';

/// Repository contract for monthly baseline operations.
abstract class MonthlyBaselineRepository {
  /// Get all baselines
  Future<Either<Failure, List<MonthlyBaseline>>> getAllBaselines();

  /// Get baseline for a specific month (YYYY-MM)
  Future<Either<Failure, MonthlyBaseline?>> getBaselineForMonth(String month);

  /// Get the most recent baseline
  Future<Either<Failure, MonthlyBaseline?>> getLatestBaseline();

  /// Save or update baseline for a month
  Future<Either<Failure, void>> saveBaseline(MonthlyBaseline baseline);

  /// Delete a baseline
  Future<Either<Failure, void>> deleteBaseline(String baselineId);

  /// Watch baseline for a specific month
  Stream<Either<Failure, MonthlyBaseline?>> watchBaselineForMonth(String month);
}
