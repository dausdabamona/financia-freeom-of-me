import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/domain/entities/time_profile.dart';
import 'package:financial_freedom/domain/repositories/time_profile_repository.dart';

/// Parameters for SaveTimeProfile use case
class SaveTimeProfileParams extends Equatable {
  final double workHoursPerWeek;
  final double obligationHoursPerWeek;
  final double freeHoursPerWeek;

  const SaveTimeProfileParams({
    required this.workHoursPerWeek,
    required this.obligationHoursPerWeek,
    required this.freeHoursPerWeek,
  });

  @override
  List<Object?> get props => [workHoursPerWeek, obligationHoursPerWeek, freeHoursPerWeek];
}

/// Use case to save time freedom profile
///
/// "Dari 168 jam hidupmu setiap minggu, berapa yang benar-benar milikmu?"
class SaveTimeProfile extends UseCase<void, SaveTimeProfileParams> {
  final TimeProfileRepository repository;

  SaveTimeProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveTimeProfileParams params) async {
    // Validation
    if (params.workHoursPerWeek < 0) {
      return const Left(ValidationFailure(
        message: 'Jam kerja tidak boleh negatif',
      ));
    }

    if (params.obligationHoursPerWeek < 0) {
      return const Left(ValidationFailure(
        message: 'Jam kewajiban tidak boleh negatif',
      ));
    }

    if (params.freeHoursPerWeek < 0) {
      return const Left(ValidationFailure(
        message: 'Jam bebas tidak boleh negatif',
      ));
    }

    // Check total doesn't exceed awake hours (168 - 56 sleep = 112 awake hours)
    final totalHours = params.workHoursPerWeek +
        params.obligationHoursPerWeek +
        params.freeHoursPerWeek;

    if (totalHours > 120) {
      return const Left(ValidationFailure(
        message: 'Total jam melebihi jam terjaga per minggu. Pastikan perhitunganmu realistis.',
      ));
    }

    final now = DateTime.now();
    final profile = TimeProfile(
      id: now.millisecondsSinceEpoch.toString(),
      workHoursPerWeek: params.workHoursPerWeek,
      obligationHoursPerWeek: params.obligationHoursPerWeek,
      freeHoursPerWeek: params.freeHoursPerWeek,
      createdAt: now,
      updatedAt: now,
    );

    return repository.saveProfile(profile);
  }
}
