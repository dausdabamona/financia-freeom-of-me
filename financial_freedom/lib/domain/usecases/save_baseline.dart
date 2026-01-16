import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/domain/entities/monthly_baseline.dart';
import 'package:financial_freedom/domain/repositories/monthly_baseline_repository.dart';

/// Parameters for SaveBaseline use case
class SaveBaselineParams extends Equatable {
  final double essentialCost;
  final double optionalCost;
  final double safetyBuffer;
  final String? notes;

  const SaveBaselineParams({
    required this.essentialCost,
    required this.optionalCost,
    required this.safetyBuffer,
    this.notes,
  });

  @override
  List<Object?> get props => [essentialCost, optionalCost, safetyBuffer, notes];
}

/// Use case to save monthly baseline costs
///
/// "Berapa biaya minimum agar hidupmu tetap bermartabat dan tenang?"
class SaveBaseline extends UseCase<void, SaveBaselineParams> {
  final MonthlyBaselineRepository repository;

  SaveBaseline(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveBaselineParams params) async {
    // Validation
    if (params.essentialCost < 0) {
      return const Left(ValidationFailure(
        message: 'Biaya esensial tidak boleh negatif',
      ));
    }

    if (params.optionalCost < 0) {
      return const Left(ValidationFailure(
        message: 'Biaya opsional tidak boleh negatif',
      ));
    }

    if (params.safetyBuffer < 0) {
      return const Left(ValidationFailure(
        message: 'Buffer keamanan tidak boleh negatif',
      ));
    }

    final now = DateTime.now();
    final month = DateFormat('yyyy-MM').format(now);

    final baseline = MonthlyBaseline(
      id: now.millisecondsSinceEpoch.toString(),
      month: month,
      essentialCost: params.essentialCost,
      optionalCost: params.optionalCost,
      safetyBuffer: params.safetyBuffer,
      notes: params.notes,
      createdAt: now,
      updatedAt: now,
    );

    return repository.saveBaseline(baseline);
  }
}
