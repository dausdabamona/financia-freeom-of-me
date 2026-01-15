import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/core/errors/failures.dart';

/// Base class for all use cases.
///
/// Type: The return type of the use case
/// Params: The parameters required by the use case
///
/// Example:
/// ```dart
/// class GetBurnRate extends UseCase<BurnRate, GetBurnRateParams> {
///   @override
///   Future<Either<Failure, BurnRate>> call(GetBurnRateParams params) async {
///     // implementation
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when the use case doesn't require any parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
