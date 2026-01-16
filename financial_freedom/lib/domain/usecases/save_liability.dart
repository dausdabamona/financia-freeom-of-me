import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/domain/entities/liability.dart';
import 'package:financial_freedom/domain/repositories/liability_repository.dart';

/// Parameters for SaveLiability use case
class SaveLiabilityParams extends Equatable {
  final String name;
  final double remainingBalance;
  final double monthlyPayment;
  final double? interestRate;
  final String? notes;

  const SaveLiabilityParams({
    required this.name,
    required this.remainingBalance,
    required this.monthlyPayment,
    this.interestRate,
    this.notes,
  });

  @override
  List<Object?> get props => [name, remainingBalance, monthlyPayment, interestRate, notes];
}

/// Use case to save a liability
///
/// "Hutang mengikat waktumu. Kita lihat dengan jujur."
class SaveLiability extends UseCase<void, SaveLiabilityParams> {
  final LiabilityRepository repository;

  SaveLiability(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveLiabilityParams params) async {
    // Validation
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure(
        message: 'Nama hutang tidak boleh kosong',
      ));
    }

    if (params.remainingBalance < 0) {
      return const Left(ValidationFailure(
        message: 'Sisa hutang tidak boleh negatif',
      ));
    }

    if (params.monthlyPayment < 0) {
      return const Left(ValidationFailure(
        message: 'Cicilan bulanan tidak boleh negatif',
      ));
    }

    final now = DateTime.now();
    final liability = Liability(
      id: now.millisecondsSinceEpoch.toString(),
      name: params.name.trim(),
      remainingBalance: params.remainingBalance,
      monthlyPayment: params.monthlyPayment,
      interestRate: params.interestRate,
      notes: params.notes,
      createdAt: now,
      updatedAt: now,
    );

    return repository.saveLiability(liability);
  }
}
