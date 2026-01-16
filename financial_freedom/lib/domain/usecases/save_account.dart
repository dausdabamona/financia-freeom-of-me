import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_freedom/core/errors/failures.dart';
import 'package:financial_freedom/core/usecases/usecase.dart';
import 'package:financial_freedom/domain/entities/account.dart';
import 'package:financial_freedom/domain/repositories/account_repository.dart';

/// Parameters for SaveAccount use case
class SaveAccountParams extends Equatable {
  final String name;
  final AccountType type;
  final double balance;
  final bool isLiquid;

  const SaveAccountParams({
    required this.name,
    required this.type,
    required this.balance,
    required this.isLiquid,
  });

  @override
  List<Object?> get props => [name, type, balance, isLiquid];
}

/// Use case to save a new account
///
/// "Kamu menyimpan uang di mana saja saat ini?"
class SaveAccount extends UseCase<void, SaveAccountParams> {
  final AccountRepository repository;

  SaveAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveAccountParams params) async {
    // Validation
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure(
        message: 'Nama akun tidak boleh kosong',
      ));
    }

    if (params.balance < 0) {
      return const Left(ValidationFailure(
        message: 'Saldo tidak boleh negatif. Kita mulai dari kejujuran.',
      ));
    }

    final now = DateTime.now();
    final account = Account(
      id: now.millisecondsSinceEpoch.toString(),
      name: params.name.trim(),
      type: params.type,
      balance: params.balance,
      isLiquid: params.isLiquid,
      createdAt: now,
      updatedAt: now,
    );

    return repository.saveAccount(account);
  }
}
