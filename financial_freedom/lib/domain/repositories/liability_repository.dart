import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/domain/entities/liability.dart';

/// Repository contract for liability operations.
abstract class LiabilityRepository {
  /// Get all liabilities
  Future<Either<Failure, List<Liability>>> getAllLiabilities();

  /// Get liability by id
  Future<Either<Failure, Liability>> getLiabilityById(String id);

  /// Get total remaining balance of all liabilities
  Future<Either<Failure, double>> getTotalRemainingBalance();

  /// Get total monthly payment of all liabilities
  Future<Either<Failure, double>> getTotalMonthlyPayment();

  /// Save a new liability
  Future<Either<Failure, void>> saveLiability(Liability liability);

  /// Update an existing liability
  Future<Either<Failure, void>> updateLiability(Liability liability);

  /// Delete a liability
  Future<Either<Failure, void>> deleteLiability(String liabilityId);

  /// Watch all liabilities for changes
  Stream<Either<Failure, List<Liability>>> watchAllLiabilities();
}
