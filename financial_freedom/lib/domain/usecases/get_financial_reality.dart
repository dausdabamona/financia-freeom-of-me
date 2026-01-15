import 'package:dartz/dartz.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/domain/entities/financial_snapshot.dart';
import 'package:financial_freedom/domain/repositories/financial_repository.dart';

/// Use case to get current financial reality.
///
/// This is the core of the Reality Engine - it fetches the latest
/// financial snapshot which contains all calculated metrics:
/// - Burn Rate
/// - Runway
/// - Salary Dependency
/// - Freedom Score
class GetFinancialReality extends UseCase<FinancialSnapshot, NoParams> {
  final FinancialRepository repository;

  GetFinancialReality(this.repository);

  @override
  Future<Either<Failure, FinancialSnapshot>> call(NoParams params) {
    return repository.getLatestSnapshot();
  }
}
